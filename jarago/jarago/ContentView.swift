//
//  ContentView.swift
//  jarago
//
//  Created by Gojaehyun on 8/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SleepViewModel()
    @State private var selectedTab = 0
    @State private var showingTodaySummary = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                SleepView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "bed.double.fill")
                Text("취침")
            }
            .tag(0)
            
            NavigationView {
                RecordsView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("기록")
            }
            .tag(1)
            
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("설정")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetToSleepTab"))) { _ in
            print("📱 탭 변경 알림 받음: 취침 탭으로 이동")
            selectedTab = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowTodaySummary"))) { _ in
            print("📊 오늘의 수면 요약 표시")
            showingTodaySummary = true
        }
        .fullScreenCover(isPresented: $showingTodaySummary) {
            if let lastRecord = viewModel.lastSleepRecord {
                SleepReviewInputView(record: lastRecord, viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
