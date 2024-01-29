import SwiftUI

struct ContentView: View {
    @ObservedObject var navigationModel: NavigationModel = NavigationModel()
    @EnvironmentObject var handModel: HandTrackerModel

    public var body: some View {
        ZStack {
            if let currentPage = navigationModel.navigationStack.last {
                currentPage.page
                    .id(navigationModel.pageId)
            }

            VStack {
                HStack(alignment: .top, spacing: PaddingSizes._12) {
                    Spacer()

                    /*
                    if PermissionModel.shared.getPermissionState(permission: .camera) != .unknown,
                        handModel.quality == .NotDetected
                    {
                        Popup(expanded: true, collapsedIcon: "info.circle") {
                            VStack(spacing: PaddingSizes._32) {
                                Text("Vision Quality Too Low")
                                    .font(FontStyles.Title2.font)

                                Text(
                                    "Oculi can’t detect your hands. Make sure you’re in a well lit area and 1-2 feet away from your device."
                                )
                                .font(FontStyles.Body.font)
                                .frame(maxWidth: 250)
                            }
                        }
                    }
                     */

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
