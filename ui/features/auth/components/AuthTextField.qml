import QtQuick
import QtQuick.Layouts
import "../../../components/inputs"

// Pre-configured AppTextInput for the auth wizard fields. Encapsulates the
// shared sizing/color defaults every auth page was repeating, while still
// allowing per-field overrides (label, placeholder, password, helperText...).
AppTextInput {
    id: root

    fieldHeight: 52
    backgroundColor: "#F5F5F5"
    textColor: "#1F2937"
    labelColor: "#1F2937"
    placeholderColor: "#9CA3AF"
    borderColor: "#E5E7EB"
    focusColor: "#2563EB"
    errorColor: "#EF4444"

    Layout.fillWidth: true
    Layout.preferredHeight: 76
    Layout.topMargin: 12
}