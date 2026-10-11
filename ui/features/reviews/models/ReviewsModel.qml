import QtQuick 2.15

ListModel {
    id: root

    property int minRating: 0

    function reload(sourceModel) {
        clear();
        for (let i = 0; i < sourceModel.count; ++i) {
            const row = sourceModel.at(i);     // needs Q_INVOKABLE at(int) on the C++ model
            if (row.rating >= root.minRating)
                append(row);
        }
    }
}
