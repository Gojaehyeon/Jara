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
        List {
            if viewModel.sleepRecords.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bed.double")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("아직 수면 기록이 없어요")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("취침 탭에서 첫 번째 수면을 기록해보세요!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.sleepRecords) { record in
                    RecordRowView(record: record)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var chartView: some View {
        VStack(spacing: 20) {
            if viewModel.sleepRecords.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("차트를 표시할 데이터가 없어요")
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
                                    icon: "clock.fill",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "총 기록",
                                    value: "\(viewModel.sleepRecords.count)일",
                                    icon: "calendar.fill",
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(record.date.formatted(.dateTime.month().day()))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(record.formattedDuration)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("취침")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(record.formattedBedtime)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("기상")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(record.formattedWakeTime)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
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