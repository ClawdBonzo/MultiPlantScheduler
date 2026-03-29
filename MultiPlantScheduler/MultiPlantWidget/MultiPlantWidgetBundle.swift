import WidgetKit
import SwiftUI

@main
struct MultiPlantWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallPlantWidget()
        MediumPlantWidget()
    }
}
