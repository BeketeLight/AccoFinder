import QtQuick

ListModel {
    id: propertyListModel

    // ========== DUMMY PROPERTIES ==========

    ListElement {
        propertyId: "prop_001"
        title: "Modern 2 Bedroom Apartment"
        description: "Spacious and well-lit apartment located in a quiet neighborhood. Close to shops, schools and public transport."
        price: 450000
        propertyType: "WHOLE"
        district: "Lilongwe"
        village: "Area 47"
        location: "Area 47, Lilongwe"
        status: "VERIFIED"
        isVerified: true
        amenities: "Wi-Fi,Parking,Security,Water"
        landlord: "John Banda"
        landlordPhone: "+265 999 123 456"
        imageUrl: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&h=400&fit=crop"
        imageUrls: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=600&h=400&fit=crop"
        isActive: true
    }

    ListElement {
        propertyId: "prop_002"
        title: "Spacious 3 Bedroom House with Garden"
        description: "Beautiful family house with a large garden, borehole and wall fence. Ideal for a family."
        price: 780000
        propertyType: "WHOLE"
        district: "Blantyre"
        village: "Nyambadwe"
        location: "Nyambadwe, Blantyre"
        status: "VERIFIED"
        isVerified: true
        amenities: "Parking,Security,Water,Electricity,Garden"
        landlord: "Mary Phiri"
        landlordPhone: "+265 888 654 321"
        imageUrl: "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop"
        imageUrls: "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop"
        isActive: true
    }

    ListElement {
        propertyId: "prop_003"
        title: "Affordable Single Room"
        description: "Clean and affordable single room suitable for students or young professionals."
        price: 85000
        propertyType: "ROOM"
        district: "Blantyre"
        village: "Chilomoni"
        location: "Chilomoni, Blantyre"
        status: "PENDING"
        isVerified: false
        amenities: "Water,Electricity"
        landlord: "Peter Mwale"
        landlordPhone: "+265 999 111 222"
        imageUrl: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&h=400&fit=crop"
        imageUrls: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=600&h=400&fit=crop"
        isActive: true
    }

    ListElement {
        propertyId: "prop_004"
        title: "Luxury Studio Apartment"
        description: "Fully furnished luxury studio in the city centre with modern finishes and great views."
        price: 320000
        propertyType: "STUDIO"
        district: "Lilongwe"
        village: "City Centre"
        location: "City Centre, Lilongwe"
        status: "VERIFIED"
        isVerified: true
        amenities: "Wi-Fi,Parking,Security,A/C,Furnished"
        landlord: "Grace Chirwa"
        landlordPhone: "+265 888 777 666"
        imageUrl: "https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=600&h=400&fit=crop"
        imageUrls: "https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=600&h=400&fit=crop"
        isActive: true
    }

    ListElement {
        propertyId: "prop_005"
        title: "Shared 4 Bedroom House"
        description: "Nice shared house with friendly housemates. Each room has its own key."
        price: 150000
        propertyType: "SHARED"
        district: "Blantyre"
        village: "Namiwawa"
        location: "Namiwawa, Blantyre"
        status: "VERIFIED"
        isVerified: true
        amenities: "Wi-Fi,Water,Electricity,Security"
        landlord: "James Nkhoma"
        landlordPhone: "+265 999 333 444"
        imageUrl: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=600&h=400&fit=crop"
        imageUrls: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop"
        isActive: true
    }

    ListElement {
        propertyId: "prop_006"
        title: "Executive 2 Bedroom Flat"
        description: "Executive flat in a quiet and secure area. Perfect for professionals."
        price: 550000
        propertyType: "WHOLE"
        district: "Lilongwe"
        village: "Area 10"
        location: "Area 10, Lilongwe"
        status: "VERIFIED"
        isVerified: true
        amenities: "Wi-Fi,Parking,Security,Water,Electricity"
        landlord: "Ruth Banda"
        landlordPhone: "+265 888 222 111"
        imageUrl: "https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=600&h=400&fit=crop"
        imageUrls: "https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=600&h=400&fit=crop"
        isActive: true
    }

    ListElement {
        propertyId: "prop_007"
        title: "Cozy 1 Bedroom Cottage"
        description: "Charming cottage with a small garden. Peaceful environment."
        price: 180000
        propertyType: "WHOLE"
        district: "Zomba"
        village: "Zomba Town"
        location: "Zomba Town, Zomba"
        status: "PENDING"
        isVerified: false
        amenities: "Water,Electricity,Garden"
        landlord: "Daniel Kachale"
        landlordPhone: "+265 999 555 777"
        imageUrl: "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=600&h=400&fit=crop"
        imageUrls: "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop"
        isActive: true
    }

    ListElement {
        propertyId: "prop_008"
        title: "Premium Penthouse Suite"
        description: "Luxury penthouse with panoramic views, modern kitchen and private balcony."
        price: 1200000
        propertyType: "WHOLE"
        district: "Blantyre"
        village: "Mandala"
        location: "Mandala, Blantyre"
        status: "VERIFIED"
        isVerified: true
        amenities: "Wi-Fi,Parking,Security,A/C,Furnished,Balcony"
        landlord: "Linda Moyo"
        landlordPhone: "+265 888 999 000"
        imageUrl: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=600&h=400&fit=crop"
        imageUrls: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=600&h=400&fit=crop"
        isActive: true
    }

    ListElement {
        propertyId: "prop_009"
        title: "Student Friendly Room"
        description: "Affordable room near Chancellor College. Ideal for students."
        price: 65000
        propertyType: "ROOM"
        district: "Zomba"
        village: "Near Chancellor College"
        location: "Near Chancellor College, Zomba"
        status: "VERIFIED"
        isVerified: true
        amenities: "Water,Electricity,Wi-Fi"
        landlord: "Esther Phiri"
        landlordPhone: "+265 999 444 555"
        imageUrl: "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=600&h=400&fit=crop"
        imageUrls: "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&h=400&fit=crop"
        isActive: true
    }

    ListElement {
        propertyId: "prop_010"
        title: "Family House with Borehole"
        description: "Spacious family house with borehole, wall fence and large yard."
        price: 420000
        propertyType: "WHOLE"
        district: "Blantyre"
        village: "Bangwe"
        location: "Bangwe, Blantyre"
        status: "PENDING"
        isVerified: false
        amenities: "Parking,Security,Water,Electricity,Borehole"
        landlord: "Samuel Chirwa"
        landlordPhone: "+265 888 666 333"
        imageUrl: "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop"
        imageUrls: "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop"
        isActive: true
    }
}
