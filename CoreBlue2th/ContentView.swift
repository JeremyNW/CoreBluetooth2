//
//  ContentView.swift
//  CoreBlue2th
//
//  Created by Jeremy Warren on 12/28/22.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject private var contentVM = ContentViewModel()
    @State private var audioPlayer: AVAudioPlayer!
    
    
    var body: some View {
        NavigationView {
            VStack {
                List(contentVM.peripherals, id: \.self) { peripheral in
                    Button {
                        contentVM.didSelectPeripheral(peripheral)
                        contentVM.isConnecting = true
                    } label: {
                        HStack {
                            Text(peripheral.name ?? "Unnamed Device")
                            if contentVM.isConnecting,
                                peripheral.name == contentVM.selectedPeripheral?.name, contentVM.selectedPeripheral != nil {
                                Spacer()
                                ProgressView()
                            }
                            if contentVM.isConnected,
                               peripheral.name == contentVM.selectedPeripheral?.name {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .symbolRenderingMode(.multicolor)
                            }
                        }
                    }
                }
                Button {
                    self.audioPlayer.play()
                } label: {
                    Text("Mambo #5")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.system(size: 18))
                        .padding()
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .background(Color.orange)
                .cornerRadius(25)
            }
            
            .onAppear {
                
                let audioPath = Bundle.main.path(forResource: "Mambo6", ofType: "mp3")!
                let url = URL(string: audioPath)!
                do {
                    
                    try self.audioPlayer = AVAudioPlayer(contentsOf: url)
                } catch {
                    print(error.localizedDescription, error)
                }
            }
            .navigationTitle("Bluetooth")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
