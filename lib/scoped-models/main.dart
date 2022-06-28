import 'package:scoped_model/scoped_model.dart';
import './connected_model.dart';

/// Scoped Model to handle all http request from backend
class MainModel extends Model with ConnectedModel, FeatureModel, UtilityModel {}
