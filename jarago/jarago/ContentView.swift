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
    @State private var navigateToDetail = false
    @State private var targetRecord: SleepRecord?
    
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
                RecordsView(viewModel: viewModel, navigateToDetail: $navigateToDetail, targetRecord: $targetRecord)
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("기록")
            }
            .tag(1)
            
            NavigationView {
                SettingsView(viewModel: viewModel)
            }
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
            print("📊 수면 기록 완료 - 후기 입력 모달 표시")
            print("📊 현재 sleepRecords 개수: \(viewModel.sleepRecords.count)")
            if let lastRecord = viewModel.lastSleepRecord {
                print("📊 마지막 기록: \(lastRecord.formattedDuration)")
                showingTodaySummary = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToRecordDetail"))) { notification in
            print("📊 후기 입력 완료 - 디테일뷰로 이동")
            if let record = notification.object as? SleepRecord {
                print("📊 이동할 기록: \(record.formattedDuration)")
                targetRecord = record
                selectedTab = 1 // 기록 탭으로 이동
                navigateToDetail = true
            }
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
