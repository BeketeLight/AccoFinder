import QtQuick

ListModel {
    id: propertyListModel

    // ========== DUMMY DATA (replace later with real C++ model) ==========

    ListElement {
        propertyId: "prop_001"
        title: "Modern 2 Bedroom Apartment"
        location: "Area 47, Lilongwe"
        price: 450000
        imageUrl: ""
        status: "Available"
        isVerified: true
        category: "Apartments"
    }

    ListElement {
        propertyId: "prop_002"
        title: "Spacious 3 Bedroom House with Garden"
        location: "Nyambadwe, Blantyre"
        price: 780000
        imageUrl: ""
        status: "Available"
        isVerified: true
        category: "Houses"
    }

    ListElement {
        propertyId: "prop_003"
        title: "Affordable Single Room"
        location: "Chilomoni, Blantyre"
        price: 85000
        imageUrl: ""
        status: "Pending"
        isVerified: false
        category: "Rooms"
    }

    ListElement {
        propertyId: "prop_004"
        title: "Luxury Studio Apartment"
        location: "City Centre, Lilongwe"
        price: 320000
        imageUrl: ""
        status: "Available"
        isVerified: true
        category: "Studios"
    }

    ListElement {
        propertyId: "prop_005"
        title: "Shared 4 Bedroom House"
        location: "Namiwawa, Blantyre"
        price: 150000
        imageUrl: ""
        status: "Booked"
        isVerified: false
        category: "Shared"
    }

    ListElement {
        propertyId: "prop_006"
        title: "Executive 2 Bedroom Flat"
        location: "Area 10, Lilongwe"
        price: 550000
        imageUrl: ""
        status: "Available"
        isVerified: true
        category: "Apartments"
    }

    ListElement {
        propertyId: "prop_007"
        title: "Cozy 1 Bedroom Cottage"
        location: "Zomba Town"
        price: 180000
        imageUrl: ""
        status: "Available"
        isVerified: false
        category: "Houses"
    }

    ListElement {
        propertyId: "prop_008"
        title: "Premium Penthouse Suite"
        location: "Mandala, Blantyre"
        price: 1200000
        imageUrl: ""
        status: "Available"
        isVerified: true
        category: "Luxury"
    }

    ListElement {
        propertyId: "prop_009"
        title: "Student Friendly Room"
        location: "Near Chancellor College, Zomba"
        price: 65000
        imageUrl: ""
        status: "Available"
        isVerified: false
        category: "Rooms"
    }

    ListElement {
        propertyId: "prop_010"
        title: "Family House with Borehole"
        location: "Bangwe, Blantyre"
        price: 420000
        imageUrl: ""
        status: "Pending"
        isVerified: true
        category: "Houses"
    }
}
