function formatCurrency(value) {
    var num = Number(value)
    if (isNaN(num)) return "MK 0"
    var parts = Math.round(num).toString().split(".")
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return "MK " + parts[0]
}
