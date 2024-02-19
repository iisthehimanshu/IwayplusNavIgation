import 'package:flutter/material.dart';

import 'APIMODELS/buildingAllModel.dart';
import 'Elements/buildingCard.dart';

class HomeNestedSearch extends SearchDelegate{
  List<buildingAllModel> searchList=[];

  HomeNestedSearch(List<buildingAllModel> initialSearchList) {
    searchList = initialSearchList;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: (){
            query = '';
          },
          icon: const Icon(Icons.clear)
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: (){
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<buildingAllModel> bbsearchList = [];
    for(var item in searchList){
      if(item.buildingName!.toLowerCase().contains(query.toLowerCase())){
        bbsearchList.add(item);
      }
    }
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        var data = bbsearchList[index];
        return buildingCard(imageURL: data.photo??"",
          Name: data.buildingName??"",
          Tag: data.category?? "", Address: data.address?? "", Distance: 190, NumberofBuildings: 3, bid: data.sId??"",);
      },

    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<buildingAllModel> bbsearchList = [];
    for (var item in searchList) {
      if (item.buildingName!.toLowerCase().contains(query.toLowerCase()) || item.venueName!.toLowerCase().contains(query.toLowerCase())) {
        bbsearchList.add(item);
      }
    }
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        var data = bbsearchList[index];
        return buildingCard(imageURL: data.photo ?? "",
          Name: data.buildingName ?? "",
          Tag: data.category ?? "",
          Address: data.address ?? "",
          Distance: 190,
          NumberofBuildings: 3,
          bid: data.sId ?? "",);
      },
      itemCount: bbsearchList.length,

    );
  }
}