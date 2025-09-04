import SwiftUI
import Charts

struct RecordsView: View {
    @ObservedObject var viewModel: SleepViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // 탭 선택기
            Picker("View", selection: $selectedTab) {
                Text("목록").tag(0)
                Text("차트").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            
            if selectedTab == 0 {
                recordsListView
            } else {
                chartView
            }
        }
        .navigationTitle("수면 기록")
        .navigationBarTitleDisplayMode(.large)
    }
    
        private var recordsListView: some View {
        Group {
            if viewModel.sleepRecords.isEmpty {
                VStack(spacing: 20) {
                    Spacer()

                    Image(systemName: "bed.double")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("아직 수면 기록이 없습니다")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                
            } else {
                List {
                    ForEach(viewModel.sleepRecords.sorted(by: { $0.date > $1.date })) { record in
                        NavigationLink(destination: SleepRecordDetailView(record: record)) {
                            RecordRowView(record: record)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private var chartView: some View {
        VStack(spacing: 20) {
            if viewModel.sleepRecords.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("차트 데이터가 없습니다")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // 7일 수면 시간 차트
                        VStack(alignment: .leading, spacing: 16) {
                            Text("최근 7일 수면 시간")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Chart {
                                ForEach(viewModel.recordsForLastDays(7).reversed(), id: \.id) { record in
                                    BarMark(
                                        x: .value("날짜", record.date, unit: .day),
                                        y: .value("수면 시간", record.durationHours)
                                    )
                                    .foregroundStyle(Color.blue.gradient)
                                    .cornerRadius(4)
                                }
                                
                                RuleMark(y: .value("목표", viewModel.currentSleepGoal))
                                    .foregroundStyle(.red)
                                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                                    .annotation(position: .leading) {
                                        Text("목표")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                            }
                            .frame(height: 200)
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisValueLabel {
                                        Text("\(value.as(Double.self)?.formatted(.number.precision(.fractionLength(1))) ?? "")시간")
                                            .font(.caption)
                                    }
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { value in
                                    AxisValueLabel {
                                        Text(value.as(Date.self)?.formatted(.dateTime.weekday(.abbreviated)) ?? "")
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        
                        // 통계 정보
                        VStack(spacing: 16) {
                            Text("수면 통계")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 20) {
                                StatCard(
                                    title: "평균 수면",
                                    value: "\(viewModel.averageSleepDuration.formatted(.number.precision(.fractionLength(1))))시간",
                                    icon: nil,
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "총 기록",
                                    value: "\(viewModel.sleepRecords.count)일",
                                    icon: nil,
                                    color: .green
                                )
                            }
                        }
                        .padding(20)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
        }
    }
}

struct RecordRowView: View {
    let record: SleepRecord
    
    var body: some View {
        HStack(spacing: 16) {
            // 날짜
            Text(record.formattedDate)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            // 취침/기상 시간
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("취침")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(record.formattedBedtime)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("기상")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(record.formattedWakeTime)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            // 총 수면 시간
            Text(record.formattedDuration)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String?
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
} 

#Preview {
    let viewModel = SleepViewModel()
    
    // 더미 데이터 추가
    let dummyRecords = [
        SleepRecord(
            bedtime: Date().addingTimeInterval(-28800), // 8시간 전
            wakeTime: Date(),
            fatigueLevel: 4,
            bedtimeMessage: "오늘은 정말 피곤했어요. 내일은 더 좋은 하루가 되길 바라요.",
            insomniaMessages: [
                InsomniaMessage(message: "잠 못 드는 밤..뭘 하고 있나요?", isFromUser: false),
                InsomniaMessage(message: "그냥 생각이 많아서요"),
                InsomniaMessage(message: "걱정되는 일이 있나요?")
            ]
        ),
        SleepRecord(
            bedtime: Date().addingTimeInterval(-86400 - 25200), // 어제 7시간 전
            wakeTime: Date().addingTimeInterval(-86400),
            fatigueLevel: 3,
            bedtimeMessage: "내일은 중요한 미팅이 있어서 긴장돼요.",
            insomniaMessages: [
                InsomniaMessage(message: "잠 못 드는 밤..뭘 하고 있나요?", isFromUser: false),
                InsomniaMessage(message: "미팅 준비 때문에요"),
                InsomniaMessage(message: "충분히 준비하셨으니 괜찮을 거예요")
            ]
        ),
        SleepRecord(
            bedtime: Date().addingTimeInterval(-172800 - 27000), // 2일 전 7.5시간 전
            wakeTime: Date().addingTimeInterval(-172800),
            fatigueLevel: 2,
            bedtimeMessage: "오늘은 운동을 많이 해서 좋았어요.",
            insomniaMessages: []
        ),
        SleepRecord(
            bedtime: Date().addingTimeInterval(-259200 - 30600), // 3일 전 8.5시간 전
            wakeTime: Date().addingTimeInterval(-259200),
            fatigueLevel: 5,
            bedtimeMessage: "너무 피곤해서 바로 잠들 것 같아요.",
            insomniaMessages: [
                InsomniaMessage(message: "잠 못 드는 밤..뭘 하고 있나요?", isFromUser: false),
                InsomniaMessage(message: "아무것도 안 하고 있어요"),
                InsomniaMessage(message: "그럼 편안히 쉬세요")
            ]
        ),
        SleepRecord(
            bedtime: Date().addingTimeInterval(-345600 - 23400), // 4일 전 6.5시간 전
            wakeTime: Date().addingTimeInterval(-345600),
            fatigueLevel: 1,
            bedtimeMessage: "오늘은 기분이 좋아요!",
            insomniaMessages: []
        )
    ]
    
    viewModel.sleepRecords = dummyRecords
    
    return RecordsView(viewModel: viewModel)
}
