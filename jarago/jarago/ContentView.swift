//
//  ContentView.swift
//  jarago
//
//  Created by Gojaehyun on 8/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SleepViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                SleepView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "bed.double.fill")
                Text("취침")
            }
            
            NavigationView {
                RecordsView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("기록")
            }
            
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("설정")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
