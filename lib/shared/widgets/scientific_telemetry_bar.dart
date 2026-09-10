import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/field_sensor_data.dart';
import '../animations/editorial_transitions.dart';

class ScientificTelemetryBar extends StatelessWidget {
  final FieldSensorData sensorData;
  final String currentLocale;

  const ScientificTelemetryBar({
    super.key,
    required this.sensorData,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const PulseIndicator(color: AppColors.field, size: 6.0),
                  const SizedBox(width: 8),
                  Text(
                    l10n.text('sensorTelemetry').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.leaf,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (sensorData.isDemoData) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warningText.withValues(alpha: 0.15),
                        border: Border.all(color: AppColors.warningText.withValues(alpha: 0.5)),
                      ),
                      child: const Text(
                        'DEMO DATA',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warningText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                'ID: ${sensorData.sensorId}',
                style: const TextStyle(
                  fontSize: 10.0,
                  fontFamily: 'monospace',
                  color: AppColors.foregroundSubtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              final itemCount = isWide ? 6 : 3;
              final itemWidth = (constraints.maxWidth - ((itemCount - 1) * 8)) / itemCount;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricItem(
                        label: currentLocale == 'ta' ? 'ஈரப்பதம்' : 'Moisture',
                        value: '${sensorData.soilMoisturePct.toStringAsFixed(1)}%',
                        width: itemWidth,
                      ),
                      _buildMetricItem(
                        label: currentLocale == 'ta' ? 'வெப்பநிலை' : 'Temp',
                        value: '${sensorData.temperatureCelsius.toStringAsFixed(1)}°C',
                        width: itemWidth,
                      ),
                      _buildMetricItem(
                        label: currentLocale == 'ta' ? 'நைட்ரஜன்' : 'Nitrogen',
                        value: '${sensorData.nitrogenPpm.toStringAsFixed(0)} ppm',
                        width: itemWidth,
                      ),
                      if (isWide) ...[
                        _buildMetricItem(
                          label: currentLocale == 'ta' ? 'மண் pH' : 'Soil pH',
                          value: sensorData.phLevel.toStringAsFixed(1),
                          width: itemWidth,
                        ),
                        _buildMetricItem(
                          label: currentLocale == 'ta' ? 'நீர் மட்டம்' : 'Water Lvl',
                          value: '${sensorData.waterLevel.toStringAsFixed(1)} cm',
                          width: itemWidth,
                        ),
                        _buildMetricItem(
                          label: currentLocale == 'ta' ? 'சூரிய ஒளி' : 'Light',
                          value: '${(sensorData.ambientLight / 1000).toStringAsFixed(0)}k lx',
                          width: itemWidth,
                        ),
                      ],
                    ],
                  ),
                  if (!isWide) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricItem(
                          label: currentLocale == 'ta' ? 'மண் pH' : 'Soil pH',
                          value: sensorData.phLevel.toStringAsFixed(1),
                          width: itemWidth,
                        ),
                        _buildMetricItem(
                          label: currentLocale == 'ta' ? 'நீர் மட்டம்' : 'Water Lvl',
                          value: '${sensorData.waterLevel.toStringAsFixed(1)} cm',
                          width: itemWidth,
                        ),
                        _buildMetricItem(
                          label: currentLocale == 'ta' ? 'சூரிய ஒளி' : 'Light',
                          value: '${(sensorData.ambientLight / 1000).toStringAsFixed(0)}k lx',
                          width: itemWidth,
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.borderBright, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9.0,
              fontWeight: FontWeight.w600,
              color: AppColors.foregroundSubtle,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.straw,
            ),
          ),
        ],
      ),
    );
  }
}

