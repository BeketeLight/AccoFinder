#ifndef EPAYMENTSTATUS_H
#define EPAYMENTSTATUS_H

enum class PaymentStatus {
    Initiated,
    Pending,
    Success,
    Failed,
    Refunded
};

#endif // EPAYMENTSTATUS_H
