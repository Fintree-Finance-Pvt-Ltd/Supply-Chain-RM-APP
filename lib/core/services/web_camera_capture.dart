// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
 
// class WebCameraCapture extends StatefulWidget {
//   const WebCameraCapture({super.key});
 
//   @override
//   State<WebCameraCapture> createState() => _WebCameraCaptureState();
// }
 
// class _WebCameraCaptureState extends State<WebCameraCapture> {
//   CameraController? controller;
//   XFile? captured;
 
//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }
 
//   Future<void> _initCamera() async {
//     final cams = await availableCameras();
//     controller = CameraController(cams.first, ResolutionPreset.medium);
//     await controller!.initialize();
//     setState(() {});
//   }
 
//   Future<void> _take() async {
//     final img = await controller!.takePicture();
//     Navigator.pop(context, img);
//   }
 
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
 
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: controller == null || !controller!.value.isInitialized
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//               children: [
//                 CameraPreview(controller!),
//                 Positioned(
//                   bottom: 40,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: FloatingActionButton(
//                       onPressed: _take,
//                       child: const Icon(Icons.camera),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//     );
//   }
// }
 
 

 import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
 
class WebCameraCapture extends StatefulWidget {
  const WebCameraCapture({super.key});
 
  @override
  State<WebCameraCapture> createState() => _WebCameraCaptureState();
}
 
class _WebCameraCaptureState extends State<WebCameraCapture> {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;
 
  @override
  void initState() {
    super.initState();
    _initCamera();
  }
 
  Future<void> _initCamera() async {
    cameras = await availableCameras();
 
    controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.medium,
    );
 
    await controller!.initialize();
    setState(() {});
  }
 
  Future<void> _switchCamera() async {
    if (cameras.length < 2) return;
 
    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
 
    await controller?.dispose();
 
    controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.medium,
    );
 
    await controller!.initialize();
    setState(() {});
  }
 
  Future<void> _take() async {
    final img = await controller!.takePicture();
    Navigator.pop(context, img);
  }
 
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller == null || !controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(controller!),
 
                /// Capture Button
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      onPressed: _take,
                      child: const Icon(Icons.camera),
                    ),
                  ),
                ),
 
                /// Switch Camera Button
                Positioned(
                  top: 40,
                  right: 20,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _switchCamera,
                    child: const Icon(Icons.cameraswitch),
                  ),
                ),
              ],
            ),
    );
  }
}
 