import 'dart:math';
import 'package:ml_linalg/matrix.dart';

class KalmanFilter {
  final Matrix F;
  final Matrix H;
  final Matrix Q;
  final Matrix R;
  Matrix X;
  Matrix P;
  final double dt;

  KalmanFilter({
    required this.dt,
    required List<double> initialState,
  })  : F = Matrix.fromList([
    [1, 0, dt, 0],
    [0, 1, 0, dt],
    [0, 0, 1, 0],
    [0, 0, 0, 1],
  ]),
        H = Matrix.fromList([
          [1, 0, 0, 0],
          [0, 1, 0, 0],
        ]),
        Q = Matrix.fromList([
          [0.1, 0, 0, 0],
          [0, 0.1, 0, 0],
          [0, 0, 0.01, 0],
          [0, 0, 0, 0.01],
        ]),
        R = Matrix.fromList([
          [3, 0],
          [0, 3],
        ]),
        X = Matrix.fromList([
          [initialState[0]],
          [initialState[1]],
          [initialState[2]],
          [initialState[3]],
        ]),
        P = Matrix.fromList([
          [1, 0, 0, 0],
          [0, 1, 0, 0],
          [0, 0, 1, 0],
          [0, 0, 0, 1],
        ]);

  List<double> predictAndUpdate(List<double> measurement) {
    Matrix Z = Matrix.fromList([
      [measurement[0]],
      [measurement[1]]
    ]);

    // Prediction step
    Matrix X_pred = F * X;
    Matrix P_pred = (F * P * F.transpose()) + Q;

    // Kalman gain
    Matrix K = (P_pred * H.transpose()) * ((H * P_pred * H.transpose() + R).inverse());

    // Update step
    X = X_pred + (K * (Z - (H * X_pred)));
    P = (Matrix.fromList([
      [1, 0, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 1, 0],

      [0, 0, 0, 1],
    ]) - (K * H)) * P_pred;

    return [X[0][0], X[1][0]];
  }
}

void main() {
  final int numSteps = 50;
  KalmanFilter kf = KalmanFilter(dt: 1.0, initialState: [0, 0, 1, 0.5]);
  Random rand = Random();

  List<List<double>> truePath = [];
  List<List<double>> gpsMeasurements = [];
  List<List<double>> estimates = [];

  for (int i = 0; i < numSteps; i++) {
    double lat = rand.nextDouble() * 50;
    double lon = rand.nextDouble() * 50;
    gpsMeasurements.add([lat, lon]);

    List<double> estimate = kf.predictAndUpdate([lat, lon]);
    estimates.add(estimate);
  }

  print("GPS Measurements: $gpsMeasurements");
  print("Estimates: $estimates");
}
