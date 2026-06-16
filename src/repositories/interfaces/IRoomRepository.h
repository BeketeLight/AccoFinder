#ifndef IROOMREPOSITORY_H
#define IROOMREPOSITORY_H

class IRoomRepository
{
    public:
        IRoomRepository(){}

        virtual void createRoom(const QString& id,
                                const QString& propertyId,
                                const QString& type,
                                bool available) = 0;
        virtual void getRooms() = 0;
        virtual void getRoomById(const QString& id) = 0;
        virtual void updateRoom(Room* room) = 0;
        virtual void deleteRoom(const QString& id) = 0;

        ~IRoomRepository(){}


};

#endif // IROOMREPOSITORY_H
