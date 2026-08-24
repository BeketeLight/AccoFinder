import QtQuick

Item {
    id: root

    readonly property alias agentsModel: agentsModelId

    property int activeAgents: 0
    property real averageCommission: 0

    function refresh() {
        var active = 0
        var totalRate = 0
        for (var i = 0; i < agentsModelId.count; i++) {
            var a = agentsModelId.get(i)
            if (a.active) active++
            totalRate += a.commissionRate
        }
        root.activeAgents = active
        root.averageCommission = agentsModelId.count > 0 ? totalRate / agentsModelId.count : 0
    }

    function nextAgentId() {
        return "AG-" + String(100 + agentsModelId.count + 1)
    }

    function addAgent(payload) {
        agentsModelId.append({
            agentId: payload.agentId,
            name: payload.name,
            email: payload.email,
            phone: payload.phone,
            area: payload.area,
            commissionRate: payload.commissionRate,
            active: true
        })
        refresh()
    }

    function updateAgent(agentId, updates) {
        for (var i = 0; i < agentsModelId.count; i++) {
            if (agentsModelId.get(i).agentId === agentId) {
                var a = agentsModelId.get(i)
                if (updates.area !== undefined) a.area = updates.area
                if (updates.commissionRate !== undefined) a.commissionRate = updates.commissionRate
                if (updates.active !== undefined) a.active = updates.active
                agentsModelId.set(i, a)
                break
            }
        }
        refresh()
    }

    function findAgent(agentId) {
        for (var i = 0; i < agentsModelId.count; i++) {
            var a = agentsModelId.get(i)
            if (a.agentId === agentId)
                return { agentId: a.agentId, name: a.name, email: a.email, phone: a.phone,
                         area: a.area, commissionRate: a.commissionRate, active: a.active }
        }
        return null
    }

    ListModel {
        id: agentsModelId

        ListElement { agentId: "AG-101"; name: "Yankho Mwale"; email: "yankho.mwale@gmail.com"; phone: "+265 995 444 010"; area: "Lilongwe"; commissionRate: 10; active: true }
        ListElement { agentId: "AG-102"; name: "Chilumba Chirwa"; email: "chilumba.c@gmail.com"; phone: "+265 993 771 220"; area: "Blantyre"; commissionRate: 12; active: false }
        ListElement { agentId: "AG-103"; name: "Fatsani Zimba"; email: "fatsani.z@gmail.com"; phone: "+265 997 310 845"; area: "Mzuzu"; commissionRate: 8; active: true }
        ListElement { agentId: "AG-104"; name: "Dalitso Kachale"; email: "dalitso.k@gmail.com"; phone: "+265 882 645 091"; area: "Zomba"; commissionRate: 10; active: true }
    }

    Component.onCompleted: refresh()
}
