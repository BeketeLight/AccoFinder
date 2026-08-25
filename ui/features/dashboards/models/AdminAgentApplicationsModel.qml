import QtQuick

Item {
    id: root

    readonly property alias applicationsModel: applicationsModelId
    readonly property alias pendingModel: pendingModelId

    property int pendingCount: 0

    function refresh() {
        var pending = 0
        for (var i = 0; i < applicationsModelId.count; i++) {
            if (applicationsModelId.get(i).status === "Pending") pending++
        }
        root.pendingCount = pending
        refreshPending()
    }

    function refreshPending() {
        pendingModelId.clear()
        for (var i = 0; i < applicationsModelId.count; i++) {
            var a = applicationsModelId.get(i)
            pendingModelId.append({
                applicationId: a.applicationId, name: a.name, email: a.email,
                phone: a.phone, area: a.area, status: a.status,
                appliedDate: a.appliedDate
            })
        }
    }

    function findApplication(applicationId) {
        for (var i = 0; i < applicationsModelId.count; i++) {
            var a = applicationsModelId.get(i)
            if (a.applicationId === applicationId) {
                var docs = []
                if (a.docId && a.docId.length > 0)
                    docs.push({ type: a.docId, name: a.docIdFile, status: "Pending" })
                if (a.docLicense && a.docLicense.length > 0)
                    docs.push({ type: a.docLicense, name: a.docLicenseFile, status: "Pending" })
                if (a.docProof && a.docProof.length > 0)
                    docs.push({ type: a.docProof, name: a.docProofFile, status: "Pending" })
                if (a.docPhoto && a.docPhoto.length > 0)
                    docs.push({ type: a.docPhoto, name: a.docPhotoFile, status: "Pending" })
                return {
                    applicationId: a.applicationId, name: a.name, email: a.email,
                    phone: a.phone, area: a.area, status: a.status,
                    appliedDate: a.appliedDate, nationalId: a.nationalId,
                    licenseType: a.licenseType, experience: a.experience,
                    motivation: a.motivation, references: a.references,
                    documents: docs
                }
            }
        }
        return null
    }

    function setStatus(applicationId, status) {
        for (var i = 0; i < applicationsModelId.count; i++) {
            var a = applicationsModelId.get(i)
            if (a.applicationId === applicationId) {
                a.status = status
                applicationsModelId.set(i, a)
                break
            }
        }
        refresh()
    }

    ListModel {
        id: applicationsModelId

        ListElement {
            applicationId: "APP-001"
            name: "Chilumba Mwale"
            email: "chilumba.mwale@gmail.com"
            phone: "+265 991 234 567"
            area: "Lilongwe"
            status: "Pending"
            appliedDate: "20 Aug 2026"
            nationalId: "MA1234567"
            licenseType: "Real Estate License A"
            experience: "5 years working with residential properties in Lilongwe. Previously managed 20+ rental units for private landlords."
            motivation: "I want to help connect tenants with quality accommodation in Lilongwe and expand AccoFinder's reach in the central region."
            references: "John Banda - Lilongwe Property Association (+265 888 111 222)"
            docId: "National ID Card"
            docIdFile: "chilumba_id.pdf"
            docLicense: "Real Estate License"
            docLicenseFile: "chilumba_license.pdf"
            docProof: "Proof of Address"
            docProofFile: "chilumba_proof.pdf"
        }
        ListElement {
            applicationId: "APP-002"
            name: "Yankho Nkhoma"
            email: "yankho.nkhoma@gmail.com"
            phone: "+265 882 345 678"
            area: "Blantyre"
            status: "Pending"
            appliedDate: "22 Aug 2026"
            nationalId: "MA9876543"
            licenseType: "Real Estate License B"
            experience: "3 years in commercial property management in Blantyre. Managed listings for 2 commercial complexes."
            motivation: "Blantyre is a growing market and I believe my local network can help AccoFinder onboard more properties faster."
            references: "Mary Phiri - Blantyre Estate Agents Board (+265 999 333 444)"
            docId: "National ID Card"
            docIdFile: "yankho_id.pdf"
            docLicense: "Real Estate License"
            docLicenseFile: "yankho_license.pdf"
            docPhoto: "Passport Photo"
            docPhotoFile: "yankho_photo.jpg"
        }
    }

    ListModel { id: pendingModelId }

    Component.onCompleted: refresh()
}
