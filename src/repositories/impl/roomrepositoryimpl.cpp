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
    RoomDto dto(id,propertyId,type,available);
    APIClient::instance().post(
        "room/create",
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
        }
        );
}

void RoomRepositoryImpl::getRooms()
{
    APIClient::instance().get(
        "room/",
        [this](bool success,
               const QJsonObject& response)
        {
            if(success)
            {
                QJsonArray roomsArray = response["data"].toArray();
                for(const QJsonValue& value: std::as_const(roomsArray))
                {
                    m_rooms.append(RoomDto::fromJson(value.toObject()).toDomainModel());
                }

                emit roomsLoaded(m_rooms);
            }
        }
    );
}

void RoomRepositoryImpl::getRoomById(const QString &id)
{
    APIClient::instance().get(
        "room/:" + id,
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
        }
    );
}

void RoomRepositoryImpl::updateRoom(Room *room)
{
    // APIClient::instance().patch(
    //     "room/:" + id,
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
        "room/:" + id,
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
        }
        );
}
