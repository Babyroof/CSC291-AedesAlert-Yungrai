class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationSum,
  });

  final DateTime date;
  final double tempMax;
  final double tempMin;
  final double precipitationSum;
}

class WeatherForecastModel {
  const WeatherForecastModel({required this.days});

  final List<DailyForecast> days;

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'] as Map<String, dynamic>;
    final dates = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final minTemps = (daily['temperature_2m_min'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final precipitation = (daily['precipitation_sum'] as List)
        .map((e) => ((e as num?) ?? 0).toDouble())
        .toList();

    final days = List.generate(
      dates.length,
      (i) => DailyForecast(
        date: DateTime.parse(dates[i]),
        tempMax: maxTemps[i],
        tempMin: minTemps[i],
        precipitationSum: precipitation[i],
      ),
    );

    return WeatherForecastModel(days: days);
  }
}
