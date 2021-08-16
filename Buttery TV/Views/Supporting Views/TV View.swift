//
//  TV View.swift
//  JW Media Player
//
//  Created by Jonathan Holland on 7/29/21.
//

import SwiftUI
import Buttery

struct TV_View<Content>: View where Content: View {
    
    @Binding var isOn: Bool
    var content: () -> Content
    
    init(isOn: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        _isOn = isOn
        self.content = content
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
//                Text("TV - Width: \(proxy.size.width) - Height: \(proxy.size.height)")
                HStack(spacing: -20) {
                    Rectangle()
                        .foregroundColor(Color.bBlue)
                        .frame(width: proxy.size.width * 0.025, height: proxy.size.height * 0.20, alignment: .center)
                        .cornerRadius(20)
                        .rotationEffect(.init(degrees: -45), anchor: .bottom)
                    Rectangle()
                        .foregroundColor(Color.bBlue)
                        .frame(width: proxy.size.width * 0.025, height: proxy.size.height * 0.20, alignment: .center)
                        .cornerRadius(20)
                        .rotationEffect(.init(degrees: 45), anchor: .bottom)
                }.offset(y: 20)
                
                VStack {
                    HStack {
                        ZStack {
                            HStack {
                                content()
                            }
                            .frame(width: proxy.size.width * 0.75, height: proxy.size.height * 0.6, alignment: .center)
                            .background(Color.black)
                            .cornerRadius(20)
                            .whiteNoise(in: proxy.size, isOn: isOn)
                        }
                    }
                    .background(Color.accentGray)
                    .cornerRadius(20)
                }
                .padding(8)
                .background(Color.bBlue)
                .cornerRadius(20)
                .align(.center)
                
                ZStack {
                    HStack {
                        Spacer()
                        HStack {}
                            .frame(width: proxy.size.width * 0.065, height: proxy.size.height * 0.08, alignment: .center)
                            .background(Color.bBlue)
                            .cornerRadius(20)
                            .offset(y: -8)
                        Spacer()
                        
                        Spacer()
                        HStack {}
                            .frame(width: proxy.size.width * 0.065, height: proxy.size.height * 0.08, alignment: .center)
                            .background(Color.bBlue)
                            .cornerRadius(20)
                            .offset(y: -8)
                        Spacer()
                    }
                }
                
//                PowerButton(isOn: $isOn) {
//                    $isOn.wrappedValue.toggle()
//                }
//                .offset(y: -60)
            }
//            .frame(minWidth: proxy.size.width * 0.5, minHeight: proxy.size.height * 0.5)
        }
        
    }
    
}

struct TV_View_Previews: PreviewProvider {
    static var previews: some View {
        TV_View(isOn: .constant(true)) {
            
        }
    }
}

extension View {
    func whiteNoise(in size: CGSize, isOn: Bool) -> some View {
        Rectangle()
            .fill(isOn ? Color.white:.clear)
            .frame(width: size.width * 0.80, height: size.height * 0.7, alignment: .center)
            .mask(self.blur(radius: 8))
            .overlay(self.blur(radius: 5 - CGFloat(1 * 5)))
    }
}
