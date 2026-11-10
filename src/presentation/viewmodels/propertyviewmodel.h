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

    // Search results live in their own model so a search never overwrites
    // the home feed, the admin listing, or the agent's own listings.
    Q_PROPERTY(PropertyListModel* searchResultModel READ searchResultModel CONSTANT)

    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

    // True between a search request start and the response. Drives the
    // spinner in SearchPropertiesScreen. Does not affect the home feed.
    Q_PROPERTY(bool isSearching READ isSearching NOTIFY isSearchingChanged)
public:
    explicit PropertyViewModel(QObject *parent = nullptr);

    PropertyListModel* propertyListModel() const { return m_propertyListModel; }
    PropertyListModel* pendingListModel() const { return m_pendingListModel; }
    PropertyListModel* searchResultModel() const { return m_searchResultModel; }
    bool isLoading() const { return m_isLoading; }
    bool isSearching() const { return m_isSearching; }
    Q_INVOKABLE QVariantList propertiesForView() const;
    // Payload for the single-property review detail, built from the shared list
    // model. Empty map when the id is not loaded. Lets callers (e.g. a dashboard
    // activity row) open the detail directly without an intermediate list.
    Q_INVOKABLE QVariantMap registrationPayloadFor(const QString& propertyId) const;
    Q_INVOKABLE int pendingPropertiesCount() const;
    Q_INVOKABLE int verifiedPropertiesCount() const;
    Q_INVOKABLE void getProperties(const QString& owner = QString());
    // Fire a search. Debouncing happens in QML (the 300ms Timer), not here —
    // by the time this is called, the user has actually stopped typing.
    // Cancellation of stale responses happens in the repository via a token.
    Q_INVOKABLE void searchProperties(const QString& search,
                                      const QString& propertyType,
                                      const QString& district,
                                      const QString& village,
                                      const QStringList& amenities,
                                      double minPrice,
                                      double maxPrice,
                                      int page = 1,
                                      int limit = 20);
    // Clear search results and reset state. Called by the clear button and by
    // SearchPropertiesScreen.onDestruction.
    Q_INVOKABLE void clearSearch();
    // Admin-only shared listing: fetches every verification status (not just
    // VERIFIED) into propertyListModel, for the admin's all-properties view.
    Q_INVOKABLE void getAdminProperties();
    Q_INVOKABLE void getPropertiesByStatus(const QString& status);
    // Fill pendingListModel with the listings that still need a decision by
    // walking the given listing owners (agents) one request at a time, then
    // emit pendingListingsLoaded(). Owners are walked in order and a failed
    // request only skips that owner, so one bad id cannot empty the queue.
    Q_INVOKABLE void loadPendingListings(const QStringList& ownerIds);
    // Fetch every listing awaiting a decision in one admin-scoped request and
    // fill pendingListModel. Preferred over loadPendingListings(ownerIds): the
    // listing's owner is a user id, which is not necessarily present in the
    // agent list, so the owner walk can miss listings the dashboard counts.
    Q_INVOKABLE void loadAllPendingListings();
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
    bool m_isSearching = false;

    PropertyListModel* m_searchResultModel = nullptr;
    void setSearching(bool searching);
    PropertyListModel* m_propertyListModel = nullptr;
    PropertyListModel* m_pendingListModel = nullptr;
    PropertyController* m_propertyController = nullptr;
    QStringList m_pendingOwnerIds;
    int m_pendingOwnerIndex = 0;

    void setLoading(bool loading);
    void fetchNextOwnerListings();

private slots:
    void onPropertiesLoaded(QList<Property*>& properties);
    void onSearchResultsLoaded(QList<Property*>& properties, int page);
    void onOwnedPropertiesLoaded(QList<Property*>& properties);
    void onPendingPropertiesLoaded(QList<Property*>& properties);
    void onGetPropertyById(Property* property);
    void onUpdateProperty(Property* property);
    void onCreateProperty(Property* property);
    void onPropertyDeleted(const QString& houseId);
    void onPropertyError(const QString& error);

signals:
    void isLoadingChanged(bool isLoading);
    void isSearchingChanged();
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
