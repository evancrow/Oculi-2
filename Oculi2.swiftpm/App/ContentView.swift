import SwiftUI

struct ContentView: View {
    @EnvironmentObject var handModel: HandTrackerModel

    public var body: some View {
        VStack {
            Text("Hand Details:")
                .bold()
            if let hand = handModel.currentHand {
                Text("Thumb to Index: \(hand.tipDistances[0])")
                Text("Index to Middle: \(hand.tipDistances[1])")
                Text("Middle to Ring: \(hand.tipDistances[2])")
                Text("Ring to Little: \(hand.tipDistances[3])")
            }

            Text("Pose:")
                .bold()
            Text("\(handModel.currentHandPose.rawValue)")

            Text("Quality:")
                .bold()
            Text("\(handModel.quality.rawValue)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
