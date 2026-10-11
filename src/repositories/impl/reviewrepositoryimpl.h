#ifndef REVIEWREPOSITORYIMPL_H
#define REVIEWREPOSITORYIMPL_H

#include "repositories/interfaces/IReviewRepository.h"
#include "services/apiclient.h"
#include "application/dto/reviewdto.h"

class ReviewRepositoryImpl : public IReviewRepository
{
    Q_OBJECT
public:
    explicit ReviewRepositoryImpl(QObject* parent = nullptr);

    void fetchByProperty(const QString& propertyId) override;
    void fetchByAgent(const QString& agentId) override;
    void createReview(const QString& propertyId,
                      const QString& agentId,
                      int rating,
                      const QString& comment) override;
    void updateReview(const QString& id,
                      int rating,
                      const QString& comment) override;
    void deleteReview(const QString& id) override;
    void checkCanReview(const QString& propertyId)  override;
    void getSummary(const QString& propertyId)      override;          // → emits summaryLoaded(double average, int count)
};

#endif // REVIEWREPOSITORYIMPL_H