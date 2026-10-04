#ifndef PROPERTYVIEWMODEL_H
#define PROPERTYVIEWMODEL_H

#include <QObject>
#include <QStringList>
#include <QJsonArray>
#include <QVariantList>
#include <QVariantMap>
#include "application/controllers/propertycontroller.h"
#include "presentation/models/propertylistmodel.h"

class PropertyViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(PropertyListModel* propertyListModel READ propertyListModel CONSTANT)
    // Listings still waiting for an admin decision. Kept apart from the shared
    // property list because the listing endpoint only returns unverified
    // listings when the request is scoped to a single owner.
    Q_PROPERTY(PropertyListModel* pendingListModel READ pendingListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit PropertyViewModel(QObject *parent = nullptr);

    PropertyListModel* propertyListModel() const { return m_propertyListModel; }
    PropertyListModel* pendingListModel() const { return m_pendingListModel; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE QVariantList propertiesForView() const;
    Q_INVOKABLE int pendingPropertiesCount() const;
    Q_INVOKABLE int verifiedPropertiesCount() const;
    Q_INVOKABLE void getProperties(const QString& owner = QString());
    Q_INVOKABLE void getPropertiesByStatus(const QString& status);
    // Fill pendingListModel with the listings that still need a decision by
    // walking the given listing owners (agents) one request at a time, then
    // emit pendingListingsLoaded(). Owners are walked in order and a failed
    // request only skips that owner, so one bad id cannot empty the queue.
    Q_INVOKABLE void loadPendingListings(const QStringList& ownerIds);
    // Record a decision on a queued listing so it leaves the queue (or stays in
    // it when a verified listing is put back to pending).
    Q_INVOKABLE void setPendingListingStatus(const QString& propertyId,
                                             const QString& status,
                                             const QString& reason = QString());
    Q_INVOKABLE void getPropertyById(const QString& houseId);
    // Row index of the property with the given backend id in the list model
    // (-1 when the property is not currently in the model).
    Q_INVOKABLE int indexOfProperty(const QString& houseId) const;
    Q_INVOKABLE void updateProperty(int index,
                                    const QString& houseId,
                                    const QString& title,
                                    const QString& description,
                                    double price,
                                    const QString& district,
                                    const QString& village,
                                    const QStringList& amenities,
                                    const QString& landlord,
                                    const QString& landlordPhone,
                                    const QString& verificationStatus,
                                    bool isActive);
    // Minimal status update used by the admin approve/reject flow. Persists the
    // new verificationStatus on the backend (not just the local list).
    Q_INVOKABLE void updatePropertyStatus(const QString& houseId, const QString& status,
                                          const QString& reason = QString(),
                                          const QString& approvedById = QString(),
                                          const QString& approvedByName = QString());
    Q_INVOKABLE void createProperty(const QString& title,
                                    const QString& description,
                                    double price,
                                    const QString& propertyType,
                                    const QString& district,
                                    const QString& village,
                                    const QStringList& amenities,
                                    const QString& landlord,
                                    const QString& landlordPhone,
                                    const QString& verificationStatus,
                                    bool isActive,
                                    const QJsonArray& rooms = QJsonArray());
    // force bypasses the backend's active-booking guard; set only once the
    // user has confirmed the override dialog.
    Q_INVOKABLE void deleteProperty(const QString& houseId, bool force = false);
    Q_INVOKABLE void attachMedia(const QString& houseId, const QStringList& mediaIds);

private:
    int m_index = -1;
    bool m_isLoading = false;
    PropertyListModel* m_propertyListModel = nullptr;
    PropertyListModel* m_pendingListModel = nullptr;
    PropertyController* m_propertyController = nullptr;
    QStringList m_pendingOwnerIds;
    int m_pendingOwnerIndex = 0;

    void setLoading(bool loading);
    void fetchNextOwnerListings();

private slots:
    void onPropertiesLoaded(QList<Property*>& properties);
    void onOwnedPropertiesLoaded(QList<Property*>& properties);
    void onGetPropertyById(Property* property);
    void onUpdateProperty(Property* property);
    void onCreateProperty(Property* property);
    void onPropertyDeleted(const QString& houseId);
    void onPropertyError(const QString& error);

signals:
    void isLoadingChanged(bool isLoading);
    void propertyError(const QString& error);
    // Emitted once every requested owner has been walked (immediately when
    // there was no owner to walk), so callers can stop showing a loading state.
    void pendingListingsLoaded();
    // `rooms` carries the rooms created atomically with the property (each with
    // the real backend _id) so callers can map wizard room numbers to real ids.
    void propertyCreatedSignal(const QString& id, const QString& title, const QVariant& rooms = QVariant());
    void propertyUpdatedSignal(const QString& id);
    void propertyDeletedSignal(const QString& id);
    // Delete refused because rooms still hold bookings. Carries the count so
    // QML can offer a "delete anyway" override.
    void propertyDeleteBlockedSignal(int activeBookings);
};

#endif // PROPERTYVIEWMODEL_H
