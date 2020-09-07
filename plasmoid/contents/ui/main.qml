import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0                                                                                                                                                                                                
import org.kde.plasma.core 2.0 as PlasmaCore

// PlasmaComponents.Label {
//     Layout.minimumWidth : plasmoid.formFactor == PlasmaCore.Types.Horizontal ? height : 1
//     Layout.minimumHeight : plasmoid.formFactor == PlasmaCore.Types.Vertical ? width  : 1
//     text: "Hello world in plasma5";
// }



RowLayout{
    id: layout
    anchors.fill: parent
    spacing: 3
    
    property int cores: 0
    property int cores_0: 0 // 0-indexed
    property int cores_max_all: 0
    property int cores_max_single: 0
    property int cores_avg: 0
    property var samples: []
    
    PlasmaCore.DataSource {
        id: coreCount
        engine: "systemmonitor"
        connectedSources: ["system/cores"]
        interval: 1000
        
        onNewData:{
            if(sourceName== "system/cores"){
                cores = data.value
                cores_0 = data.value -1 
//                 samples.push(cores)
//                 console.log(samples)
            }
        }
    }
    
    PlasmaCore.DataSource {
        id: coreHistories
        engine: "systemmonitor"
        connectedSources: sources()
        interval: 1000
        property var values: []

        function sources() {
            var array = []

            if (cores != 0) {
                for (var i = 0; i <= cores; i++) {
                    array.push("cpu/cpu" + i + "/clock");
                }
            }
            return array;
        }
        
        
        onNewData:{
            if (data.value) {
                values.push(parseFloat(data.value))
            }
            
            if(sourceName== "cpu/cpu" + cores_0 + "/clock"){
                console.log("flip")
                console.log(values)
                
                var average = 0
                for(var i in values) { average += values[i]; }
                cores_avg = average/cores
                
                var min = Math.min.apply(null, values);
                if (min > cores_max_all) {
                    cores_max_all = min
                }
                
                var max = Math.max.apply(null, values);
                if (max > cores_max_single) {
                    cores_max_single = max
                }
                values = []
            }
        }
    }
    
//     PlasmaCore.DataSource {
//         id: coreCount
//         engine: "systemmonitor"
//         connectedSources: ["system/cores"]
//         interval: 60000
//     }
    
    Rectangle {
        color: 'darkcyan'
        Layout.fillWidth: true
        Layout.minimumWidth: 80
        Layout.preferredWidth: 120
        Layout.maximumWidth: 300
        Layout.minimumHeight: 80
        ColumnLayout {
            anchors.centerIn: parent
            Text {
                id: "core_max_all"
                color: 'white'
                anchors.centerIn: parent
                text: cores_max_all
                font.pointSize: 30

            }
            Text {
                color: 'white'
                anchors.horizontalCenter: parent
                text: "All Core Boost"
            }
        }
    }
    
    Rectangle {
        color: 'darkorange'
        Layout.fillWidth: true
        Layout.minimumWidth: 80
        Layout.preferredWidth: 120
        Layout.maximumWidth: 300
        Layout.minimumHeight: 80
        ColumnLayout {
            anchors.centerIn: parent
            Text {
                id: "core_max_single"
                color: 'white'
                anchors.centerIn: parent
                text: cores_max_single
                font.pointSize: 30
            }
            Text {
                color: 'white'
                anchors.horizontalCenter: parent
                text: 'Single Core Boost'
            }
        }
    }
    
    Rectangle {
        color: 'purple'
        Layout.fillWidth: true
        Layout.minimumWidth: 80
        Layout.preferredWidth: 120
        Layout.maximumWidth: 300
        Layout.minimumHeight: 80
        ColumnLayout {
            anchors.centerIn: parent
            Text {
                color: 'white'
                anchors.centerIn: parent
                text: cores_avg
                font.pointSize: 30
            }
            Text {
                color: 'white'
                anchors.horizontalCenter: parent
                text: 'Average'
            }
        }
    }
    Rectangle {
        color: 'darkslateblue'
        Layout.fillWidth: true
        Layout.minimumWidth: 80
        Layout.preferredWidth: 120
        Layout.maximumWidth: 300
        Layout.minimumHeight: 80
        TapHandler {
            onPressedChanged: {
                    cores_max_all = 0
                    cores_max_single = 0
                    cores_avg = 0
                    
                }
        }
        ColumnLayout {
            anchors.centerIn: parent
            
            PlasmaCore.SvgItem {
                // source - the icon to be displayed
                svg: plasmoid.file("images", "../images/icon.refresh.svg")
                // height & width set to equal the size of the parent item (the empty "Item" above)
//                 width: theme.iconSizes.dialog
//                 height: theme.iconSizes.dialog
            }
            Text {
                color: 'white'
                anchors.horizontalCenter: parent
                text: 'Reset'
                font.pointSize: 30
            }
        }
    }
    
}
