#include "roomrepositoryimpl.h"

RoomRepositoryImpl::RoomRepositoryImpl(QObject *parent)
    :QObject(parent)
{

}

void RoomRepositoryImpl::createRoom(const QString &id,
                                    const QString &propertyId,
                                    const QString &type,
                                    bool available)
{
    RoomDto dto(id,propertyId,type,0,available);
    APIClient::instance().post(
        "/rooms/",
        dto.toJson(),
        [this](bool success,
               const QJsonObject& response)
        {
            if (success)
            {
                RoomDto roomDTO = RoomDto::fromJson(response["data"].toObject());
                QSharedPointer<Room> room= roomDTO.toDomainModel();

                emit roomCreated(room);
            }
        }, false
        );
}

void RoomRepositoryImpl::getRooms()
{
    // The backend /rooms/ endpoint paginates with a server default of 10 rows
    // (limit=10), so without an explicit limit only the newest handful of
    // rooms would ever be cached. Per-property room counts (roomsForProperty)
    // then read as 0 for every property whose rooms fall outside that page.
    // Request the whole catalogue so the counts are accurate for all cards.
    APIClient::instance().get(
        "/rooms/?limit=10000",
        [this](bool success,
               const QJsonObject& response)
        {
            if(success)
            {
                // Fresh fetch, so always replace (not append) the cached rooms.
                // Without this, every getRooms() call re-appends the full list and
                // the count grows on each dashboard refresh (e.g. 6 -> 12).
                m_rooms.clear();
                QJsonArray roomsArray = response["data"].toArray();
                for(const QJsonValue& value: std::as_const(roomsArray))
                {
                    m_rooms.append(RoomDto::fromJson(value.toObject()).toDomainModel());
                }

                emit roomsLoaded(m_rooms);
            }
        }, false
    );
}

void RoomRepositoryImpl::getRoomById(const QString &id)
{
    APIClient::instance().get(
        "/rooms/" + id,
        [this](bool success,
               const QJsonObject& response)
        {
            if(success)
            {
                RoomDto roomDTO = RoomDto::fromJson(response["data"].toObject());
                emit roomLoaded(roomDTO.toDomainModel());
            }
            else {
                emit error("no room was found");
            }
        }, false
    );
}

void RoomRepositoryImpl::updateRoom(Room *room)
{
    // APIClient::instance().patch(
    //     "/rooms/" + id,
    //     [this](bool success,
    //            const QJsonObject& response)
    //     {
    //         if(success)
    //         {
    //             RoomDto roomDTO = RoomDto::fromJson(response["data"].toObject());
    //             emit roomLoaded(roomDTO.toDomainModel());
    //         }
    //         else {
    //             emit error("no room was found");
    //         }
    //     }
    // );
    
}

void RoomRepositoryImpl::deleteRoom(const QString &id)
{
    APIClient::instance().del(
        "/rooms/" + id,
        [this](bool success,
               const QJsonObject& response)
        {
            if(success)
            {
                RoomDto roomDTO = RoomDto::fromJson(response["data"].toObject());
                emit roomLoaded(roomDTO.toDomainModel());
            }
            else {
                emit error("no room was found");
            }
        }, false
        );
}
