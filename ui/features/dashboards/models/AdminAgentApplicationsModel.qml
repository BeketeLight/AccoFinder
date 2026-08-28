import QtQuick

Item {
    id: root

    // Delegate-facing API preserved. Real data sourced from the C++
    // AgentApplicationViewModel (AgentController -> /agent-applications/ API).
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
        return AgentApplicationViewModel.findApplication(applicationId)
    }

    function setStatus(applicationId, status) {
        if (status === "Approved")
            AgentApplicationViewModel.approve(applicationId)
        else if (status === "Rejected")
            AgentApplicationViewModel.reject(applicationId)
    }

    ListModel {
        id: applicationsModelId
    }

    ListModel {
        id: pendingModelId
    }

    function reload() {
        applicationsModelId.clear()
        var m = AgentApplicationViewModel.applicationListModel
        for (var i = 0; i < m.size; i++) {
            var item = m.at(i)
            applicationsModelId.append({
                applicationId: item.agentId, name: item.name, email: item.email,
                phone: item.phone, area: item.area, status: item.status,
                appliedDate: item.appliedDate
            })
        }
        root.refresh()
    }

    Connections {
        target: AgentApplicationViewModel.applicationListModel
        function onCountChanged() { root.reload() }
        function onDataChanged() { root.reload() }
        function onModelReset() { root.reload() }
    }

    Component.onCompleted: {
        AgentApplicationViewModel.getApplications()
    }
}
