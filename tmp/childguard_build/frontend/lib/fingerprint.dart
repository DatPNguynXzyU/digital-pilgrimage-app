import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Android's fingerprint-specific API prevents face authentication fallback.
class FingerprintAuth {
 static const channel=MethodChannel('childguard/fingerprint');
 Future<bool> available()async=>await channel.invokeMethod<bool>('available')??false;
 Future<bool> authenticate(BuildContext context)async{
  if(!await available())throw Exception('Thiết bị cần cảm biến và vân tay đã đăng ký trong Android Settings.');
  if(!context.mounted)return false;
  bool closed=false;
  final dialog=showDialog<void>(context:context,barrierDismissible:false,builder:(ctx)=>PopScope(canPop:false,child:AlertDialog(title:const Text('Xác thực vân tay'),content:const Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.fingerprint,size:72,color:Color(0xFF23816C)),SizedBox(height:16),Text('Chạm ngón tay vào cảm biến vân tay của điện thoại.')]),actions:[TextButton(onPressed:()async{await channel.invokeMethod('cancel');},child:const Text('Hủy'))])));
  try{return await channel.invokeMethod<bool>('authenticate')??false;}
  finally{if(context.mounted&&!closed){closed=true;Navigator.of(context,rootNavigator:true).pop();}await dialog;}
 }
}
