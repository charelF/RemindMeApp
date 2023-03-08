import SwiftUI

struct Test: View {
  
  @State private var offset: CGFloat = 0
  @State private var oldOffset: CGFloat = 0
  let maxLeadingOffset: CGFloat
  let minTrailingOffset: CGFloat
  
  enum VisibleButton {
          case none
          case left
          case right
      }
  
  func reset() {
          visibleButton = .none
          offset = 0
          oldOffset = 0
      }
  
  @State private var visibleButton: VisibleButton = .none
  
  var body: some View {
    ScrollView{
      ForEach(0..<4) { _ in
        VStack {
          Text("123")
        }
        .frame(maxWidth:.infinity, maxHeight:100)
        .frame(height: 40)
        .background(Color.blue.opacity(0.2))
        .padding(5)
        .cornerRadius(20)
        .offset(x: offset)
        .gesture(
          DragGesture(minimumDistance: 15, coordinateSpace: .local)
            .onChanged({ (value) in
              let totalSlide = value.translation.width + oldOffset
              if  (0...Int(maxLeadingOffset) ~= Int(totalSlide)) || (Int(minTrailingOffset)...0 ~= Int(totalSlide)) { //left to right slide
                  withAnimation{
                      offset = totalSlide
                  }
              }
              ///can update this logic to set single button action with filled single button background if scrolled more then buttons width
          })
                    .onEnded({ value in
                        withAnimation {
                          if visibleButton == .left && value.translation.width < -20 { ///user dismisses left buttons
                            reset()
                         } else if  visibleButton == .right && value.translation.width > 20 { ///user dismisses right buttons
                            reset()
                         } else if offset > 25 || offset < -25 { ///scroller more then 50% show button
                            if offset > 0 {
                                visibleButton = .left
                                offset = maxLeadingOffset
                            } else {
                                visibleButton = .right
                                offset = minTrailingOffset
                            }
                            oldOffset = offset
                            ///Bonus Handling -> set action if user swipe more then x px
                        } else {
                            reset()
                        }
                     }
                    })
        )
        
      }
      .padding(20)
    }
  }
    
}


struct TestPreview: PreviewProvider {
    static var previews: some View {
      Test(maxLeadingOffset: 1, minTrailingOffset: 1)
    }
}
