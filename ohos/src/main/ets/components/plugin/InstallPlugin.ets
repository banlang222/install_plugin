import {
   AbilityAware,
   AbilityPluginBinding,
   FlutterPlugin,
   FlutterPluginBinding,
   MethodCall,
   MethodCallHandler,
   MethodChannel,
   MethodResult,
 } from '@ohos/flutter_ohos';
 import { Ability, common, UIAbility, Want } from '@kit.AbilityKit';
 import { BusinessError } from '@kit.BasicServicesKit';
import { updateManager } from '@kit.StoreKit';

/** InstallPlugin **/
 export default class InstallPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
   private channel: MethodChannel | null = null;
   private context: common.UIAbilityContext | null = null;
   constructor() {
   }

   onAttachedToAbility(binding: AbilityPluginBinding): void {
     this.context = binding.getAbility().context;
   }

   onDetachedFromAbility(): void {
     throw new Error('Method not implemented.');
   }

   getUniqueClassName(): string {
     return "InstallPlugin"
   }

   onAttachedToEngine(binding: FlutterPluginBinding): void {
     this.channel = new MethodChannel(binding.getBinaryMessenger(), "install_plugin");
     this.channel.setMethodCallHandler(this)
   }

   onDetachedFromEngine(binding: FlutterPluginBinding): void {
     if (this.channel != null) {
       this.channel.setMethodCallHandler(null)
     }
   }

   onMethodCall(call: MethodCall, result: MethodResult): void {
     console.debug(`incoming call ${call.method}`);
     if (call.method == "checkUpdate") {
       try{
         updateManager.checkAppUpdate(this.context).then((checkResult: updateManager.CheckUpdateResult)=>{
           result.success(checkResult.updateAvailable == updateManager.UpdateAvailableCode.LATER_VERSION_EXIST);
         }).catch((error:BusinessError)=>{
           console.debug(`catch error:${JSON.stringify(error)}`);
           result.error(error.code.toString(), `message: ${error.message}`, `stack: ${error.stack}`);
         });
       } catch(err) {
         console.debug(`check error:${JSON.stringify(err)}`);
         result.error('00001', `message: ${JSON.stringify(err)}`, null);
       }

     } else if(call.method == "showUpdateDialog") {
       try{
         updateManager.showUpdateDialog(this.context).then((resultCode: updateManager.ShowUpdateResultCode)=>{
           result.success(resultCode == updateManager.ShowUpdateResultCode.SHOW_DIALOG_SUCCESS);
         }).catch((error:BusinessError)=>{
           console.debug(`catch error=${JSON.stringify(error)}`);
           result.error(error.code.toString(), `message: ${error.message}`, `stack: ${error.stack}`);
         });
       } catch(err) {
         console.debug(`show dialog error:${JSON.stringify(err)}`);
         result.error('00001', `message: ${JSON.stringify(err)}`, null);
       }
     } else if(call.method == 'open') {
       let want: Want = {};
       want.bundleName = call.argument('bundleName');
       want.abilityName = call.argument('abilityName');
       want.deviceId = "";
       want.uri = call.argument('uri');
       want.type = call.argument('type');
       want.flags = call.argument('flags');
       want.action = call.argument('action');
       want.moduleName = call.argument('moduleName');
       want.parameters = call.argument('parameters');
       want.entities = call.argument('entities');
       console.debug(`will start ability, want = ${JSON.stringify(want)}`);
       try{
         this.context?.startAbilityForResult(want, (error: BusinessError, r: common.AbilityResult)=>{
           if(error.code) {
             console.debug(`error: ${JSON.stringify(error)}`);
           } else {
             console.debug(`start app success :${JSON.stringify(r)}`);
             result.success(1);
           }
         });
       } catch(error) {
         console.debug(`params error:${JSON.stringify(error)}`);
       }
       result.success(1);
     }
     else {
       result.notImplemented()
     }
   }
 }