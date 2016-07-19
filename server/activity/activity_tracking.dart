import "package:log4dart/log4dart_vm.dart";
import '../model/model.dart';

final _logger = LoggerFactory.getLogger("ActivityTracking");

void trackUserRegistered(String email, bool connectionSucced){
  if (connectionSucced){
    _logger.info("Registration Success for $email");
  }else {
    _logger.info("Registration Failed for $email");
  }
}

void trackUserConnection(String email, bool connectionSucced){
  if (connectionSucced){
    _logger.info("Login Success for $email");
  }else {
    _logger.info("Login Failed for $email");
  }
}

void trackUploadArtifact(MDTApplication app,MDTArtifact artifact){
  _logger.info("ADD Artifact (v '${artifact.version}, branch:${artifact.branch}') on application ${app.platform} '${app.name}'");
}

void trackDeleteArtifact(MDTApplication app,MDTArtifact artifact){
  _logger.info("DELETE Artifact (v '${artifact.version}, branch:${artifact.branch}') on application ${app.platform} '${app.name}'");
}

void trackDownloadArtifact(MDTArtifact artifact, String email){
  _logger.info("DOWNLOAD Artifact, user:${email}, version:'${artifact.version}', branch:${artifact.version} app:${artifact.application.platform} '${artifact.application.name}'");
}

void trackCreateApp(MDTApplication app, MDTUser connectedUser){
  _logger.info("CREATE Application '${app.platform} ${app.name}' by ${connectedUser.email}");
}

void trackDeleteApp(MDTApplication app, MDTUser connectedUser){
  _logger.info("DELETE Application ${app.platform} '${app.name}' by ${connectedUser.email}");
}