
export PATH=/Users/gogetta/Developments/Dart/dart-sdk-1.13.0/bin:$PATH
pub global activate rpc
mkdir json
pub global run rpc:generate discovery -i ../server/services/application_service.dart > json/applications.json
pub global run rpc:generate discovery -i ../server/services/artifact_service.dart > json/artifacts.json
pub global run rpc:generate discovery -i ../server/services/user_service.dart > json/users.json

pub global activate discoveryapis_generator
pub global run discoveryapis_generator:generate package -i json -o client