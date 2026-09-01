import QtQuick

Item {
    id: root

    // Delegate-facing API preserved. Real data sourced from the C++
    // AgentViewModel (AgentController -> /agents/ API).
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
        AgentViewModel.addAgent(payload.firstName || payload.name || "",
                                payload.lastName || "",
                                payload.email || "",
                                payload.phone || "",
                                payload.area || "",
                                payload.commissionRate || 0)
    }

    function updateAgent(agentId, updates) {
        if (updates.active !== undefined) {
            AgentViewModel.setActive(agentId, updates.active)
        } else {
            AgentViewModel.updateAgent(agentId, updates.area || "", updates.commissionRate || 0)
        }
    }

    function setAllCommission(commissionRate) {
        AgentViewModel.setAllAgentsCommission(commissionRate)
    }

    function findAgent(agentId) {
        return AgentViewModel.findAgentById(agentId)
    }

    ListModel {
        id: agentsModelId
    }

    function reload() {
        agentsModelId.clear()
        var m = AgentViewModel.agentListModel
        var cppSize = m ? m.size() : 0
        for (var i = 0; i < cppSize; i++) {
            var item = m.at(i)
            agentsModelId.append({
                agentId: item.agentId, name: item.name, email: item.email,
                phone: item.phone, area: item.area,
                commissionRate: item.commissionRate, active: item.active
            })
        }
        root.refresh()
    }

    Connections {
        target: AgentViewModel.agentListModel
        function onCountChanged() { root.reload() }
        function onDataChanged() { root.reload() }
        function onModelReset() { root.reload() }
    }

    Component.onCompleted: {
        AgentViewModel.getAgents()
    }
}
