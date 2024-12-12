import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../../IWAYPLUS/ELEMENTS/locales.dart';
import '../ViewModel/DirectionInstructionViewModel.dart';
import 'DirectionInstructionWidget.dart';
import 'OutDoorInstructionWidget.dart';


class DirectionInstruction extends StatefulWidget {
  final DirectionInstructionViewModel viewModel;

  DirectionInstruction({required this.viewModel});

  @override
  _DirectionInstructionState createState() => _DirectionInstructionState();
}

class _DirectionInstructionState extends State<DirectionInstruction> {
  bool sourceBuildingListExpand = false;
  bool outdoorListExpand = false;
  bool destinationListExpand = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Consumer<DirectionInstructionViewModel>(
        builder: (context, vm, child) {

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //single floor
              !vm.isMultiBuilding && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: vm.sourceName, StartBuildingName: vm.sourceBuildingName, StartFloor: vm.sourceFloor, directionList: vm.directionList, IsMultiFloor: false, IsMultiBuilding: false,FirstHeight: vm.sourceUPHeight/2+screenHeight*0.125,SecondHeight: vm.sourceUPHeight/2+screenHeight*0.125, LiftString: vm.sourceLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalSourceDistance,Turns: vm.totalSourceTurns,ThirdHeight: 0,ForthHeight: 0,BuildingID: vm.sourceBID,): Container(),
              //multi floor
              !vm.isMultiBuilding && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: vm.sourceName, StartBuildingName: vm.sourceBuildingName, StartFloor: vm.sourceFloor, directionList: vm.directionList, IsMultiFloor: true, IsMultiBuilding: false,FirstHeight: (vm.sourceUPHeight/2)+screenHeight*0.125,SecondHeight: vm.sourceUPHeight/2+screenHeight*0.11,ThirdHeight: vm.sourceDownHeight/2,ForthHeight: (vm.sourceDownHeight/2)+screenHeight*0.125, LiftString: vm.sourceLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalSourceDistance,Turns: vm.totalSourceTurns,BuildingID: vm.sourceBID): Container(),

              //MultiBuilding Both Single floor
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: vm.sourceName, StartBuildingName: vm.sourceBuildingName, StartFloor: vm.sourceFloor, directionList: vm.sourceDirection, IsMultiFloor: false, IsMultiBuilding: true,FirstHeight: (vm.sourceUPHeight/2)+screenHeight*0.125,SecondHeight: vm.sourceUPHeight/2+screenHeight*0.1,ThirdHeight: 0,ForthHeight: 0, LiftString: vm.sourceLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalSourceDistance,Turns: vm.totalSourceTurns,BuildingID: vm.sourceBID): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? SizedBox(height: 20,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? OutDoorInstructionWidget(ListHeight: vm.outdoorWidgetHeight+screenHeight*0.14, TotalOutDoorMeter: vm.totalOutdoorLength, EndBuildingName: vm.destinationBuildingName, directions: vm.outdoorDirection,ShowLandmark: (vm.sourceBID==buildingAllApi.outdoorID || vm.destinationBID==buildingAllApi.outdoorID)? true : false,endName:(vm.sourceBID==buildingAllApi.outdoorID)?vm.destinationBuildingName : vm.destinationBID==buildingAllApi.outdoorID? vm.destinationName:"",): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID &&  vm.isMultiBuilding && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? SizedBox(height: 10,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: (vm.destinationBID==buildingAllApi.outdoorID)?vm.destinationBuildingName:vm.sourceBuildingName, StartBuildingName: (vm.sourceBID==buildingAllApi.outdoorID)?vm.destinationBuildingName:vm.sourceBuildingName, StartFloor: vm.destionationFloor, directionList: vm.destinationDirection, IsMultiFloor: false, IsMultiBuilding: true,FirstHeight: (vm.destinationUpHeight/2)+screenHeight*0.125,SecondHeight: vm.destinationUpHeight/2+screenHeight*0.1,ThirdHeight: 0,ForthHeight: 0, LiftString: vm.destinationLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalDestinationDistance,Turns: vm.totalDestinationTurns,reverse: true,BuildingID: vm.destinationBID): Container(),

              //MultiBuilding Source MultiFloor Destination SingleFloor
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: vm.sourceBuildingName, StartBuildingName: vm.sourceBuildingName, StartFloor: vm.sourceFloor, directionList: vm.sourceDirection, IsMultiFloor: true, IsMultiBuilding: true,FirstHeight: (vm.sourceUPHeight/2)+screenHeight*0.125,SecondHeight: vm.sourceUPHeight/2,ThirdHeight: vm.sourceDownHeight/2,ForthHeight: vm.sourceDownHeight/2+screenHeight*0.125, LiftString: vm.sourceLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalDestinationDistance,Turns: vm.totalDestinationTurns,BuildingID: vm.sourceBID): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? SizedBox(height: 20,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? OutDoorInstructionWidget(ListHeight: vm.outdoorWidgetHeight+screenHeight*0.14, TotalOutDoorMeter: vm.totalOutdoorLength, EndBuildingName: vm.destinationBuildingName, directions: vm.outdoorDirection,ShowLandmark: (vm.sourceBID==buildingAllApi.outdoorID || vm.destinationBID==buildingAllApi.outdoorID)? true : false,endName:(vm.sourceBID==buildingAllApi.outdoorID)?vm.destinationBuildingName : vm.destinationBID==buildingAllApi.outdoorID? vm.destinationName:"",): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID &&  vm.isMultiBuilding && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? SizedBox(height: 10,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: (vm.sourceBID==buildingAllApi.outdoorID)?vm.sourceBuildingName:vm.destinationBuildingName, StartBuildingName:(vm.sourceBID==buildingAllApi.outdoorID)?vm.sourceBuildingName: vm.destinationBuildingName, StartFloor: vm.destionationFloor, directionList: vm.destinationDirection, IsMultiFloor: false, IsMultiBuilding: true,FirstHeight: (vm.destinationUpHeight/2)+screenHeight*0.125,SecondHeight: vm.destinationUpHeight/2+screenHeight*0.1,ThirdHeight: vm.destinationDownHeight/2,ForthHeight: vm.destinationDownHeight/2, LiftString: vm.destinationLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalDestinationDistance,Turns: vm.totalDestinationTurns,reverse: true,BuildingID: vm.destinationBID): Container(),

              //MultiBuilding Source SingleFloor Destination MultiFloor
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: vm.sourceBuildingName, StartBuildingName: vm.sourceBuildingName, StartFloor: vm.sourceFloor, directionList: vm.sourceDirection, IsMultiFloor: false, IsMultiBuilding: true,FirstHeight: (vm.sourceUPHeight/2)+screenHeight*0.125,SecondHeight: vm.sourceUPHeight/2+screenHeight*0.1,ThirdHeight: vm.sourceDownHeight/2,ForthHeight: vm.sourceDownHeight/2, LiftString: vm.sourceLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalDestinationDistance,Turns: vm.totalDestinationTurns,BuildingID: vm.sourceBID): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && vm.isDestinationMultiFloor? SizedBox(height: 20,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && vm.isDestinationMultiFloor? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && vm.isDestinationMultiFloor? OutDoorInstructionWidget(ListHeight: vm.outdoorWidgetHeight+screenHeight*0.14, TotalOutDoorMeter: vm.totalOutdoorLength, EndBuildingName: vm.destinationBuildingName, directions: vm.outdoorDirection,ShowLandmark: (vm.sourceBID==buildingAllApi.outdoorID || vm.destinationBID==buildingAllApi.outdoorID)? true : false,endName:(vm.sourceBID==buildingAllApi.outdoorID)?vm.destinationBuildingName : vm.destinationBID==buildingAllApi.outdoorID? vm.destinationName:"",): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && vm.isDestinationMultiFloor? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID &&  vm.isMultiBuilding && !vm.isSourceMultiFloor && vm.isDestinationMultiFloor? SizedBox(height: 10,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && !vm.isSourceMultiFloor && vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: (vm.sourceBID==buildingAllApi.outdoorID)?vm.sourceBuildingName:vm.destinationBuildingName, StartBuildingName:(vm.sourceBID==buildingAllApi.outdoorID)?vm.sourceBuildingName: vm.destinationBuildingName, StartFloor: vm.destionationFloor, directionList: vm.destinationDirection, IsMultiFloor: true, IsMultiBuilding: true,FirstHeight: (vm.destinationUpHeight/2)+screenHeight*0.05,SecondHeight: vm.destinationUpHeight/2+screenHeight*0.05,ThirdHeight: vm.destinationDownHeight/2+screenHeight*0.05,ForthHeight: vm.destinationDownHeight/2+screenHeight*0.05, LiftString: vm.destinationLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalDestinationDistance,Turns: vm.totalDestinationTurns,reverse: true,BuildingID: vm.destinationBID): Container(),

              //MultiBuildong Source MultiFloor Destination MultiFloor
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: vm.sourceBuildingName, StartBuildingName: vm.sourceBuildingName, StartFloor: vm.sourceFloor, directionList: vm.sourceDirection, IsMultiFloor: true, IsMultiBuilding: true,FirstHeight: (vm.sourceUPHeight/2)+screenHeight*0.125,SecondHeight: vm.sourceUPHeight/2+screenHeight*0.1,ThirdHeight: vm.sourceDownHeight/2,ForthHeight: vm.sourceDownHeight/2, LiftString: vm.sourceLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalDestinationDistance,Turns: vm.totalDestinationTurns,BuildingID: vm.sourceBID): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && vm.isDestinationMultiFloor? SizedBox(height: 20,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && vm.isDestinationMultiFloor? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && vm.isDestinationMultiFloor? OutDoorInstructionWidget(ListHeight: vm.outdoorWidgetHeight+screenHeight*0.14, TotalOutDoorMeter: vm.totalOutdoorLength, EndBuildingName: vm.destinationBuildingName, directions: vm.outdoorDirection,ShowLandmark: (vm.sourceBID==buildingAllApi.outdoorID || vm.destinationBID==buildingAllApi.outdoorID)? true : false,endName:(vm.sourceBID==buildingAllApi.outdoorID)?vm.destinationBuildingName : vm.destinationBID==buildingAllApi.outdoorID? vm.destinationName:"",): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && vm.isDestinationMultiFloor? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && vm.isDestinationMultiFloor? SizedBox(height: 10,): Container(),
              vm.sourceBID != buildingAllApi.outdoorID &&  vm.destinationBID != buildingAllApi.outdoorID && vm.isMultiBuilding && vm.isSourceMultiFloor && vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: (vm.sourceBID==buildingAllApi.outdoorID)?vm.sourceBuildingName:vm.destinationBuildingName, StartBuildingName: (vm.sourceBID==buildingAllApi.outdoorID)?vm.sourceBuildingName:vm.destinationBuildingName, StartFloor: vm.destionationFloor, directionList: vm.destinationDirection, IsMultiFloor: true, IsMultiBuilding: true,FirstHeight: (vm.destinationUpHeight/2)+screenHeight*0.05,SecondHeight: vm.destinationUpHeight/2+screenHeight*0.05,ThirdHeight: vm.destinationDownHeight/2+screenHeight*0.05,ForthHeight: vm.destinationDownHeight/2+screenHeight*0.05, LiftString: vm.destinationLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalDestinationDistance,Turns: vm.totalDestinationTurns,reverse: true,BuildingID: vm.destinationBID): Container(),

              //Destination OutDoor Source MultiFloor
              vm.isMultiBuilding && vm.destinationBID == buildingAllApi.outdoorID && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: vm.sourceBuildingName, StartBuildingName: vm.sourceBuildingName, StartFloor: vm.sourceFloor, directionList: vm.sourceDirection, IsMultiFloor: true, IsMultiBuilding: true,FirstHeight: (vm.sourceUPHeight/2)+screenHeight*0.125,SecondHeight: vm.sourceUPHeight/2+screenHeight*0.1,ThirdHeight: vm.sourceDownHeight/2,ForthHeight: vm.sourceDownHeight/2, LiftString: vm.sourceLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalDestinationDistance,Turns: vm.totalDestinationTurns,reverse: false,BuildingID: vm.sourceBID): Container(),
              vm.isMultiBuilding && vm.destinationBID == buildingAllApi.outdoorID && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? SizedBox(height: 20,): Container(),
              vm.isMultiBuilding && vm.destinationBID == buildingAllApi.outdoorID && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
              vm.isMultiBuilding && vm.destinationBID == buildingAllApi.outdoorID && vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? OutDoorInstructionWidget(ListHeight: vm.outdoorWidgetHeight+screenHeight*0.14, TotalOutDoorMeter: vm.totalOutdoorLength, EndBuildingName: vm.destinationBuildingName, directions: vm.outdoorDirection,ShowLandmark: true,endName: vm.destinationName): Container(),

              //Destination OutDoor Source SingleFloor
              vm.isMultiBuilding && vm.destinationBID == buildingAllApi.outdoorID && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: vm.sourceBuildingName, StartBuildingName: vm.sourceBuildingName, StartFloor: vm.sourceFloor, directionList: vm.sourceDirection, IsMultiFloor: false, IsMultiBuilding: true,FirstHeight: (vm.sourceUPHeight/2)+screenHeight*0.125,SecondHeight: vm.sourceUPHeight/2+screenHeight*0.1,ThirdHeight: vm.sourceDownHeight/2,ForthHeight: vm.sourceDownHeight/2, LiftString: vm.sourceLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalDestinationDistance,Turns: vm.totalDestinationTurns,reverse: false,BuildingID: vm.sourceBID): Container(),
              vm.isMultiBuilding && vm.destinationBID == buildingAllApi.outdoorID && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? SizedBox(height: 20,): Container(),
              vm.isMultiBuilding && vm.destinationBID == buildingAllApi.outdoorID && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? OutDoorInstructionWidget(ListHeight: vm.outdoorWidgetHeight+screenHeight*0.14, TotalOutDoorMeter: vm.totalOutdoorLength, EndBuildingName: vm.destinationBuildingName, directions: vm.outdoorDirection,ShowLandmark: true,endName: vm.destinationName): Container(),

              //Source OutDoor Destination MultiFloor
              vm.isMultiBuilding && vm.sourceBID == buildingAllApi.outdoorID && !vm.isSourceMultiFloor && vm.isDestinationMultiFloor? OutDoorInstructionWidget(ListHeight: vm.outdoorWidgetHeight+screenHeight*0.14, TotalOutDoorMeter: vm.totalOutdoorLength, EndBuildingName: vm.destinationBuildingName, directions: vm.outdoorDirection,ShowLandmark: true,endName: vm.destinationBuildingName): Container(),
              vm.isMultiBuilding && vm.sourceBID == buildingAllApi.outdoorID && !vm.isSourceMultiFloor && vm.isDestinationMultiFloor? SizedBox(height: 20,): Container(),
              vm.isMultiBuilding && vm.sourceBID == buildingAllApi.outdoorID && !vm.isSourceMultiFloor && vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: vm.destinationBuildingName, StartBuildingName: vm.destinationBuildingName, StartFloor: vm.destionationFloor, directionList: vm.destinationDirection, IsMultiFloor: true, IsMultiBuilding: true,FirstHeight: (vm.destinationUpHeight/2)+screenHeight*0.125,SecondHeight: vm.destinationUpHeight/2+screenHeight*0.1,ThirdHeight: vm.destinationDownHeight/2,ForthHeight: vm.destinationDownHeight/2, LiftString: vm.destinationLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalDestinationDistance,Turns: vm.totalDestinationTurns,reverse: true,BuildingID: vm.sourceBID): Container(),

              //Source OutDoor Destination SingleFloor
              vm.isMultiBuilding && vm.sourceBID == buildingAllApi.outdoorID && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? OutDoorInstructionWidget(ListHeight: vm.outdoorWidgetHeight+screenHeight*0.14, TotalOutDoorMeter: vm.totalOutdoorLength, EndBuildingName: vm.destinationBuildingName, directions: vm.outdoorDirection,ShowLandmark: true,endName: vm.destinationBuildingName): Container(),
              vm.isMultiBuilding && vm.sourceBID == buildingAllApi.outdoorID && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? SizedBox(height: 20,): Container(),
              vm.isMultiBuilding && vm.sourceBID == buildingAllApi.outdoorID && !vm.isSourceMultiFloor && !vm.isDestinationMultiFloor? DirectionInstructionWidget(StartName: vm.destinationBuildingName, StartBuildingName: vm.destinationBuildingName, StartFloor: vm.destionationFloor, directionList: vm.destinationDirection, IsMultiFloor: false, IsMultiBuilding: true,FirstHeight: (vm.destinationUpHeight/2)+screenHeight*0.125,SecondHeight: vm.destinationUpHeight/2+screenHeight*0.1,ThirdHeight: vm.destinationDownHeight/2,ForthHeight: vm.destinationDownHeight/2, LiftString: vm.destinationLiftString,EndBuildingName: vm.destinationBuildingName,EndFloor: vm.destionationFloor,EndName: vm.destinationName,TotalDistance: vm.totalDestinationDistance,Turns: vm.totalDestinationTurns,reverse: true,BuildingID: vm.sourceBID): Container(),

              //FOR MORE SCROLLING - IMP
              SizedBox(height: screenHeight*0.3),
              //FOR MORE SCROLLING - IMP

            ],
          );
        },
      ),
    );
  }



  Widget getCustomIcon(String direction,context) {
    if (direction ==  LocaleData.gostraight.getString(context)) {
      return Icon(
        Icons.straight,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.slightright.getString(context))) {
      return Icon(
        Icons.turn_slight_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.sharpright.getString(context))) {
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.tright.getString(context))) {
      return Icon(
        Icons.turn_right,
        color: Colors.black,
        size: 32,
      );
    }  else if (direction.contains(LocaleData.uturn.getString(context))) {
      return Icon(
        Icons.u_turn_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.sharpleft.getString(context))) {
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.slightleft.getString(context))) {
      return Icon(
        Icons.turn_slight_left,
        color: Colors.black,
        size: 32,
      );

    } else if (direction.contains(LocaleData.tleft.getString(context))) {
      return Icon(
        Icons.turn_left,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains("Lift")) {
      return Padding(
        padding: const EdgeInsets.all(3.5),
        child: SvgPicture.asset("assets/elevator.svg"),
      );
    }
    // else if(direction.substring(0,4)=="Take"){
    //   return Icon(
    //     Icons.abc,
    //     color: Colors.black,
    //     size: 32,
    //   );
    // }

    else {
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.black,
        size: 32,
      );
    }
  }

}
