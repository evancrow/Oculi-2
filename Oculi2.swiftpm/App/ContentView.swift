import SwiftUI

struct ContentView: View {
    @ObservedObject var navigationModel: NavigationModel = NavigationModel()
    @EnvironmentObject var handModel: HandTrackerModel
    @EnvironmentObject var avModel: AVModel

    @State private var popupExpanded = true

    public var body: some View {
        ZStack {
            if let currentPage = navigationModel.navigationStack.last {
                currentPage.page
                    .id(navigationModel.pageId)
            }

            VStack {
                HStack(alignment: .top, spacing: PaddingSizes._12) {
                    Spacer()

                    if avModel.failedToConfigure {
                        Popup(expanded: $popupExpanded, collapsedIcon: "info.circle") {
                            VStack(spacing: PaddingSizes._32) {
                                Text("Unsupported Device")
                                    .font(FontStyles.Title2.font)

                                Text(
                                    "Oculi cannot work on your device because there is no accessible camera. Please try from your iPad or iPhone."
                                )
                                .font(FontStyles.Body.font)
                                .frame(maxWidth: 250)
                            }
                        }
                    }

                    DebugPopup()
                }

                Spacer()
            }.padding(PaddingSizes._52)
        }.environmentObject(navigationModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HandTrackerModel(interactionManager: InteractionManager()))
    }
}
