import 'dart:async';
import 'dart:convert';
import 'package:acoustic/apiservice/Api_Header.dart';
import 'package:acoustic/apiservice/Apiservice.dart';
import 'package:acoustic/custom/like_comment_share.dart';
import 'package:acoustic/custom/loader_custom_widget.dart';
import 'package:acoustic/custom/mute_icon.dart';
import 'package:acoustic/custom/no_post_available.dart';
import 'package:acoustic/model/nearByVideo.dart';
import 'package:acoustic/model/report_reason.dart';
import 'package:acoustic/model/videocomment.dart';
import 'package:acoustic/screen/usedsoundlist.dart';
import 'package:acoustic/util/constants.dart';
import 'package:acoustic/util/preferenceutils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';
import 'package:marquee/marquee.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
import 'homescreen.dart';
import 'loginscreen.dart';
import 'userprofile.dart';

class NearByScreen extends StatefulWidget {
  @override
  _NearByScreen createState() => _NearByScreen();
}

class _NearByScreen extends State<NearByScreen> {
  bool isRememberMe = false;
  bool showSpinner = false;
  bool showRed = false;
  bool showWhite = true;
  bool showGridView = true;
  bool halfStatus = true;
  bool fullStatus = false;
  bool showMore = true;
  bool showLess = false;
  PageController nearByController = PageController();
  List<int?> savedItem = <int?>[];
  late Future<List<NearByVideoData>> _getVideoFeatureBuilder;
  List<NearByVideoData> nearByVidList = <NearByVideoData>[];
  List<CommentData> commentList = <CommentData>[];
  int? selectedCommentId = 0;
  int? removeVideoIndex;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _textCommentController = TextEditingController();
  List<ReportReasonData> reportReasonData = [];
  bool adMobNative = false;
  List<String> storeAdNetworkData = [];
  int setLoop = 0;
  static const List<String> choices = <String>[
    "Delete Comment",
    "Report Comment"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _getVideoFeatureBuilder = callApiForNearByVideo();
    if (PreferenceUtils.getBooll(Constants.adAvailable) == true) {
      setLoop = PreferenceUtils.getStringList(Constants.adNetwork)!.length;
    }
    for (int i = 0; i < setLoop; i++) {
      storeAdNetworkData
          .add(PreferenceUtils.getStringList(Constants.adNetwork)![i]);
    }
    storeAdNetworkData.sort();
    for (int i = 0; i < setLoop; i++) {
      if (storeAdNetworkData[i] == "admob" &&
          PreferenceUtils.getStringList(Constants.adStatus)![i] == "1" &&
          PreferenceUtils.getStringList(Constants.adType)![i] == "Native") {
        adMobNative = true;
        advertisementManage();
        break;
      }

      else {
        adMobNative = false;
      }
    }
  }

  void advertisementManage() {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenheight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(Constants.bgblack),
          key: _scaffoldKey,
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            opacity: 1.0,
            color: Colors.transparent.withOpacity(0.2),
            progressIndicator:CustomLoader(),
            child: Container(
              margin: PreferenceUtils.getBooll(Constants.adAvailable) == true
                  ? EdgeInsets.only(bottom: 140)
                  : EdgeInsets.only(bottom: 90),
              child: showGridView == true

                  /// for grid view
                  ? LayoutBuilder(
                      builder: (BuildContext context,
                          BoxConstraints viewportConstraints) {
                        return Container(
                          child: Stack(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: viewportConstraints.maxHeight),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                        child: FutureBuilder<
                                            List<NearByVideoData>>(
                                      future: _getVideoFeatureBuilder,
                                      builder: (context, snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.done:
                                            return (snapshot.data?.length ?? 0) > 0 ?
                                            Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 10,
                                                        left: 20,
                                                        right: 20),
                                                    child: StaggeredGridView
                                                        .countBuilder(
                                                      staggeredTileBuilder:
                                                          (int index) =>
                                                              new StaggeredTile
                                                                      .count(
                                                                  2,
                                                                  index.isEven
                                                                      ? 2.5
                                                                      : 2.5),
                                                      mainAxisSpacing: 2.0,
                                                      crossAxisSpacing: 1.0,
                                                      physics:
                                                          AlwaysScrollableScrollPhysics(),
                                                      crossAxisCount: 4,
                                                      itemCount:
                                                          nearByVidList.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        bool isSaved = false;

                                                        nearByVidList[index]
                                                                    .isLike ==
                                                                false
                                                            ? isSaved = false
                                                            : isSaved = true;
                                                        return InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              showGridView =
                                                                  false;
                                                            });
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                            child:
                                                                new Container(
                                                              child: Stack(
                                                                children: [
                                                                  CachedNetworkImage(
                                                                    imageUrl: nearByVidList[index]
                                                                            .imagePath! +
                                                                        nearByVidList[index]
                                                                            .screenshot!,
                                                                    imageBuilder:
                                                                        (context,
                                                                                imageProvider) =>
                                                                            Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20.0),
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              imageProvider,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          alignment:
                                                                              Alignment.topCenter,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    placeholder: (context,
                                                                            url) =>CustomLoader(),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Image.asset(
                                                                            "images/no_image.png"),
                                                                  ),
                                                                  Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: SvgPicture
                                                                        .asset(
                                                                            "images/play_button.svg"),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            0,
                                                                        bottom:
                                                                            5),
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Container(
                                                                            alignment:
                                                                                Alignment.bottomLeft,
                                                                            child:
                                                                                Text(
                                                                              () {
                                                                                if (1 < int.parse(nearByVidList[index].viewCount!)) {
                                                                                  return "${nearByVidList[index].viewCount} Views";
                                                                                } else {
                                                                                  return "${nearByVidList[index].viewCount} View";
                                                                                }
                                                                              }(),
                                                                              style: TextStyle(color: Color(Constants.whitetext), fontSize: 16, fontFamily: Constants.appFont),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.bottomRight,
                                                                            child:
                                                                                Container(
                                                                              alignment: Alignment.bottomRight,
                                                                              child: Container(
                                                                                margin: EdgeInsets.only(right: 10),
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      if (savedItem.length != 0) {
                                                                                        if (isSaved) {
                                                                                          savedItem.remove(nearByVidList[index]);
                                                                                        } else {
                                                                                          savedItem.add(nearByVidList[index].id);
                                                                                        }
                                                                                      } else {
                                                                                        savedItem.add(nearByVidList[index].id);
                                                                                      }
                                                                                    });
                                                                                  },
                                                                                  child: isSaved
                                                                                      ? SvgPicture.asset(
                                                                                          "images/red_heart.svg",
                                                                                          width: 20,
                                                                                          height: 20,
                                                                                        )
                                                                                      : SvgPicture.asset(
                                                                                          "images/white_heart.svg",
                                                                                          width: 20,
                                                                                          height: 20,
                                                                                        ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Align(
                                                    alignment: Alignment.center,
                                                    child: NoPostAvailable(subject: 'Post',),
                                                  );
                                          case ConnectionState.none:
                                            return Container();
                                          case ConnectionState.waiting:
                                            return Container();
                                          case ConnectionState.active:
                                            return Container();
                                          default:
                                            return Container();
                                        }
                                      },
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )

                  /// for page view
                  : Container(
                      height: screenheight / 1.20,
                      child: LayoutBuilder(builder: (BuildContext context,
                          BoxConstraints viewportConstraints) {
                        return FutureBuilder<List<NearByVideoData>>(
                          future: _getVideoFeatureBuilder,
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.done:
                                return (snapshot.data?.length ?? 0) > 0
                                    ? PageView.builder(
                                        controller: nearByController,
                                        itemCount: nearByVidList.length,
                                        scrollDirection: Axis.vertical,
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {


                                          if (nearByVidList[index]
                                                      .description !=
                                                  null &&
                                              nearByVidList[index]
                                                      .description !=
                                                  '') {
                                          } else {
                                            nearByVidList[index].description =
                                                'The Status is Empty';
                                          }
                                          if (adMobNative == true) {
                                            if (index != 0 && index % 5 == 0) {
                                              return Align(
                                                alignment: Alignment.center,
                                                child: NativeAd(

                                                  height: 320,
                                                  unitId: MobileAds
                                                      .nativeAdVideoTestUnitId,
                                                  builder: (context, child) {
                                                    return Material(
                                                      elevation: 8,
                                                      child: child,
                                                    );
                                                  },
                                                  buildLayout:
                                                      mediumAdTemplateLayoutBuilder,

                                                  loading: Text(
                                                    'loading',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  error: Text(
                                                    'error',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  icon: AdImageView(size: 40),
                                                  headline: AdTextView(
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    maxLines: 1,
                                                  ),
                                                  body: AdTextView(
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      maxLines: 1),
                                                  media: AdMediaView(
                                                    height: 170,
                                                    width: MATCH_PARENT,
                                                  ),
                                                  attribution: AdTextView(
                                                    width: WRAP_CONTENT,
                                                    text: 'Ad',
                                                    decoration: AdDecoration(
                                                      border: BorderSide(
                                                          color: Colors.green,
                                                          width: 2),
                                                      borderRadius:
                                                          AdBorderRadius.all(
                                                              16.0),
                                                    ),
                                                    style: TextStyle(
                                                        color: Colors.green),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4.0,
                                                            vertical: 1.0),
                                                  ),
                                                  button: AdButtonView(
                                                    elevation: 18,
                                                    decoration: AdDecoration(
                                                        backgroundColor:
                                                            Colors.blue),
                                                    height: MATCH_PARENT,
                                                    textStyle: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              );
                                            }
                                          }

                                          return Container(
                                            child: Stack(
                                              children: <Widget>[
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                    color: Colors.transparent,
                                                    child: VideoPlayerItem(
                                                      videoUrl: nearByVidList[
                                                                  index]
                                                              .imagePath! +
                                                          nearByVidList[index]
                                                              .video!,
                                                      videoId:
                                                          nearByVidList[index]
                                                              .id,
                                                    ),
                                                  ),
                                                ),
                                                /// Middle expanded
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 4,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 15.0,
                                                                  bottom: 20),
                                                          child: ListView(
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            children: <Widget>[
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      if (PreferenceUtils.getlogin(
                                                                              Constants.isLoggedIn) ==
                                                                          true) {
                                                                        if (mounted) {
                                                                          if (nearByVidList[index].isYou ==
                                                                              true) {
                                                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen(4)));
                                                                          } else {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => UserProfileScreen(
                                                                                  userId: nearByVidList[index].user!.id,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }
                                                                        }
                                                                      } else {
                                                                        Future.delayed(
                                                                            Duration(seconds: 0),
                                                                            () => Navigator.of(context).push(
                                                                                  MaterialPageRoute(builder: (context) => LoginScreen()),
                                                                                ));
                                                                      }
                                                                    },
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          margin: EdgeInsets.only(
                                                                              left: 0,
                                                                              right: 5,
                                                                              bottom: 5),
                                                                          width:
                                                                              ScreenUtil().setWidth(36),
                                                                          height:
                                                                              ScreenUtil().setHeight(36),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            imageUrl:
                                                                                nearByVidList[index].user!.imagePath! + nearByVidList[index].user!.image!,
                                                                            imageBuilder: (context, imageProvider) =>
                                                                                CircleAvatar(
                                                                              radius: 15,

                                                                              backgroundColor: Colors.transparent,
                                                                              child: CircleAvatar(
                                                                                radius: 15,
                                                                                backgroundImage: imageProvider,
                                                                              ),

                                                                            ),
                                                                            placeholder: (context, url) => CustomLoader(),
                                                                            errorWidget: (context, url, error) =>
                                                                                Image.asset("images/no_image.png"),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                            margin:
                                                                                EdgeInsets.only(bottom: 5),
                                                                            child: Text(
                                                                              nearByVidList[index].user!.name!,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  nearByVidList[index]
                                                                              .isYou ==
                                                                          false
                                                                      ? Container(
                                                                          margin: EdgeInsets.only(
                                                                              left: 2,
                                                                              right: 2,
                                                                              bottom: 5),
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            "images/white_dot.svg",
                                                                            width:
                                                                                5,
                                                                            height:
                                                                                5,
                                                                          ),
                                                                        )
                                                                      : Container(),
                                                                  nearByVidList[index]
                                                                              .isYou ==
                                                                          false
                                                                      ? nearByVidList[index].user!.isFollowing ==
                                                                              0
                                                                          ? InkWell(
                                                                              onTap: () {
                                                                                if (PreferenceUtils.getlogin(Constants.isLoggedIn) == true) {
                                                                                  callApiForFollowRequest(nearByVidList[index].user!.id, nearByVidList[index].id);
                                                                                } else {
                                                                                  Constants.toastMessage('Please Login First To Follow');
                                                                                }
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    margin: EdgeInsets.only(left: 5, right: 2, bottom: 5),
                                                                                    child: SvgPicture.asset(
                                                                                      "images/follow.svg",
                                                                                      width: 15,
                                                                                      height: 15,
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                      margin: EdgeInsets.only(bottom: 5),
                                                                                      child: Text(
                                                                                        'Follow',
                                                                                        maxLines: 1,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          : InkWell(
                                                                              onTap: () {
                                                                                if (PreferenceUtils.getlogin(Constants.isLoggedIn) == true) {
                                                                                  callApiForUnFollowRequest(nearByVidList[index].user!.id, nearByVidList[index].id);
                                                                                } else {
                                                                                  Constants.toastMessage('Please Login First To unfollow');
                                                                                }
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    margin: EdgeInsets.only(left: 5, right: 2, bottom: 5),
                                                                                    child: SvgPicture.asset(
                                                                                      "images/follow.svg",
                                                                                      width: 15,
                                                                                      height: 15,
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                      margin: EdgeInsets.only(bottom: 5),
                                                                                      child: Text(
                                                                                        'Unfollow',
                                                                                        maxLines: 1,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            )
                                                                      : Container(),
                                                                ],
                                                              ),
                                                              Visibility(
                                                                visible: halfStatus &&
                                                                    0 <
                                                                        nearByVidList[index]
                                                                            .description!
                                                                            .length,
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              0,
                                                                          bottom:
                                                                              5),
                                                                  child: Text(
                                                                    nearByVidList[index]
                                                                            .description ??
                                                                        "",

                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        color: Color(Constants
                                                                            .whitetext),
                                                                        fontSize:
                                                                            14,
                                                                        fontFamily:
                                                                            Constants.appFont),
                                                                  ),
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: fullStatus &&
                                                                    0 <
                                                                        nearByVidList[index]
                                                                            .description!
                                                                            .length,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      halfStatus =
                                                                          !halfStatus;
                                                                      fullStatus =
                                                                          !fullStatus;
                                                                      showMore =
                                                                          !showMore;
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets.only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            0,
                                                                        bottom:
                                                                            5),
                                                                    child: Text(
                                                                      nearByVidList[index]
                                                                              .description ??
                                                                          "",
                                                                      maxLines:
                                                                          20,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          color: Color(Constants
                                                                              .whitetext),
                                                                          fontSize:
                                                                              14,
                                                                          fontFamily:
                                                                              Constants.appFont),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: showMore &&
                                                                    0 <
                                                                        nearByVidList[index]
                                                                            .description!
                                                                            .length,
                                                                child:
                                                                    Container(

                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              20,
                                                                          bottom:
                                                                              5),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        halfStatus =
                                                                            !halfStatus;
                                                                        fullStatus =
                                                                            !fullStatus;
                                                                        showMore =
                                                                            !showMore;
                                                                      });
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                          "...more",
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                              color: Color(Constants.whitetext),
                                                                              fontSize: 16,
                                                                              fontFamily: Constants.appFont),
                                                                        ),
                                                                        Container(
                                                                          margin: EdgeInsets.only(
                                                                              left: 5,
                                                                              right: 5,
                                                                              top: 0),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            "images/down_arrow.svg",
                                                                            width:
                                                                                8,
                                                                            height:
                                                                                8,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              nearByVidList[index]
                                                                          .originalAudio !=
                                                                      null
                                                                  ? InkWell(
                                                                      onTap:
                                                                          () {
                                                                        String?
                                                                            passSongId =
                                                                            '0';
                                                                        bool
                                                                            isSongIdAvailable =
                                                                            true;
                                                                        if (PreferenceUtils.getlogin(Constants.isLoggedIn) ==
                                                                            true) {
                                                                          if (nearByVidList[index].songId != '' &&
                                                                              nearByVidList[index].songId != null) {
                                                                            passSongId =
                                                                                nearByVidList[index].songId;
                                                                            isSongIdAvailable =
                                                                                true;
                                                                          } else if (nearByVidList[index].audioId != '' &&
                                                                              nearByVidList[index].audioId != null) {
                                                                            passSongId =
                                                                                nearByVidList[index].audioId;
                                                                            isSongIdAvailable =
                                                                                false;
                                                                          }
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => UsedSoundScreen(
                                                                                songId: passSongId,
                                                                                isSongIdAvailable: isSongIdAvailable,
                                                                              ),
                                                                            ),
                                                                          );
                                                                          print(
                                                                              "open sound");
                                                                        } else {
                                                                          Constants.toastMessage(
                                                                              'Please login to enter Music Gallery');
                                                                        }
                                                                      },
                                                                      child: Row(
                                                                          children: [
                                                                            Container(
                                                                              margin: EdgeInsets.only(left: 5, right: 2),
                                                                              child: SvgPicture.asset(
                                                                                "images/sound_waves.svg",
                                                                                width: 15,
                                                                                height: 15,
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: Container(
                                                                                height: 20,
                                                                                margin: EdgeInsets.only(left: 5, right: 2),
                                                                                child: Marquee(
                                                                                  text: nearByVidList[index].originalAudio ?? "UnKnown audio found",
                                                                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                                                                ),

                                                                              ),
                                                                            ),
                                                                          ]),
                                                                    )
                                                                  : Container(),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child:
                                                            CustomLikeComment(
                                                          index: index,
                                                          shareLink: nearByVidList[
                                                                      index]
                                                                  .imagePath! +
                                                              nearByVidList[
                                                                      index]
                                                                  .video!,
                                                          commentCount:
                                                              nearByVidList[
                                                                      index]
                                                                  .commentCount
                                                                  .toString(),

                                                          isLike: nearByVidList[
                                                                  index]
                                                              .isLike,
                                                          listOfAll:
                                                              nearByVidList,

                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : Align(
                                        alignment: Alignment.center,
                                        child: NoPostAvailable(subject: 'Post',),
                                      );
                              case ConnectionState.none:
                                return CustomLoader();
                              case ConnectionState.waiting:
                                return CustomLoader();
                              case ConnectionState.active:
                                return CustomLoader();
                              default:
                                return CustomLoader();
                            }
                          },
                        );
                      }),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<NearByVideoData>> callApiForNearByVideo() async {
    LocationData _locationData;
    Location _location = Location();
    setState(() {
      showSpinner = true;
    });
    _locationData = await _location.getLocation();
    await RestClient(ApiHeader().dioData())
        .getNearByVideo(_locationData.latitude, _locationData.longitude)
        .then((response) {
      if (response.success == true) {
        setState(() {
          showSpinner = false;
        });
        setState(() {
          print("lenght123456:${nearByVidList.length}");
          if (response.data!.length != 0) {
            nearByVidList.clear();
            nearByVidList.addAll(response.data!);
            print("nearbyvideo.length:${nearByVidList.length}");
          }
        });
      } else {
        setState(() {
          showSpinner = false;
        });
      }
    }).catchError((Object obj) {
      setState(() {
        showSpinner = false;
      });
      print("error:$obj");
      print(obj.runtimeType);
    });
    return nearByVidList;
  }

  Future<void> callApiForNearByVideoSearched(latitude, longitude) async {
    RestClient(ApiHeader().dioData())
        .getNearByVideo(latitude, longitude)
        .then((response) {
      if (response.success == true) {
        setState(() {
          showSpinner = false;
        });
        setState(() {
          print("lenght123456:${nearByVidList.length}");
          if (response.data!.length != 0) {
            nearByVidList.clear();
            nearByVidList.addAll(response.data!);
            print("nearbyvideo.length:${nearByVidList.length}");
          }
        });
      } else {
        setState(() {
          showSpinner = false;
        });
      }
    }).catchError((Object obj) {
      setState(() {
        showSpinner = false;
      });
      print("error:$obj");
      print(obj.runtimeType);
    });
  }

  Widget _getSocialAction({required String title, required String icon}) {
    return Container(
        margin: EdgeInsets.only(top: 15.0),
        width: 60.0,
        height: 60.0,
        child: Column(children: [
          SvgPicture.asset(icon),
          Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(title,
                style: TextStyle(fontSize: 14, color: Colors.white)),
          ),
        ]));
  }

  callApiForGetComment(int? id, int index) {
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData()).getvideocomment(id).then((response) {
      if (response.success == true) {
        setState(() {
          showSpinner = false;
          commentList.clear();
          _openCommentLayout(index, id);
        });
        setState(() {
          if (response.data!.length != 0) {
            commentList.addAll(response.data!);
          }
        });
      } else {
        setState(() {
          showSpinner = false;
          _openCommentLayout(index, id);
        });
      }
    }).catchError((Object obj) {
      Constants.toastMessage(obj.toString());



      setState(() {
        showSpinner = false;
      });
      print("error:$obj");
      print(obj.runtimeType);
    });
  }

  void callApiForLikedVideo(int? id, BuildContext context) {
    print("likeid:$id");

    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData()).likevideo(id).then((response) {
      final body = json.decode(response!);
      bool? sucess = body['success'];
      print("likevideosucees:$sucess");

      if (sucess == true) {
        setState(() {
          showSpinner = false;


          print("likevidmsg:${body['msg']}");





        });
      } else {
        setState(() {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage(msg.toString());



        });
      }
    }).catchError((Object obj) {
      Constants.toastMessage(obj.toString());




      setState(() {
        showSpinner = false;
      });
      print("error:$obj");
      print(obj.runtimeType);
    });
  }

  void _openSavedBottomSheet(int? id, int? isSaved, int? userid) {
    print("savedid123:$id");
    print("isSaved123:$isSaved");

    String save = "Save";

    if (isSaved == 1) {
      save = "UnSave";
    } else if (isSaved == 0) {
      save = "Save";
    }
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: false,
        backgroundColor: Color(Constants.bgblack),
        builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Wrap(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      openReportBottomSheet();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                      height: ScreenUtil().setHeight(50),
                      child: Text(
                        "Report",
                        style: TextStyle(
                            color: Color(Constants.whitetext),
                            fontSize: 16,
                            fontFamily: Constants.appFont),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Constants.checkNetwork()
                          .whenComplete(() => callApiForBlockUser(userid));
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                      height: ScreenUtil().setHeight(50),
                      child: Text(
                        "Block This User",
                        style: TextStyle(
                            color: Color(Constants.whitetext),
                            fontSize: 16,
                            fontFamily: Constants.appFont),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                    height: ScreenUtil().setHeight(50),
                    child: Text(
                      "I'm Not Interested",
                      style: TextStyle(
                          color: Color(Constants.whitetext),
                          fontSize: 16,
                          fontFamily: Constants.appFont),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                    height: ScreenUtil().setHeight(50),
                    child: Text(
                      "Copy Link",
                      style: TextStyle(
                          color: Color(Constants.whitetext),
                          fontSize: 16,
                          fontFamily: Constants.appFont),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Constants.checkNetwork()
                          .whenComplete(() => callApiForSavevideo(id));
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                      height: ScreenUtil().setHeight(50),
                      child: Text(
                        save,
                        style: TextStyle(
                            color: Color(Constants.whitetext),
                            fontSize: 16,
                            fontFamily: Constants.appFont),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }

  Widget _getSingleAction({required String icon}) {
    return Container(
        margin: EdgeInsets.only(top: 15.0, bottom: 20),
        width: 25.0,
        height: 25.0,
        child: SvgPicture.asset(icon));
  }

  void _openCommentLayout(int index1, videoIndex) {
    final _formKey = GlobalKey<FormState>();
    String _review = "";

    showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Color(Constants.bgblack),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter mystate) {
            mystate(() {});
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 80, left: 0, bottom: 20),
                    height: ScreenUtil().setHeight(50),
                    color: Color(0xFF1d1d1d),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Text(
                              nearByVidList[index1].commentCount.toString() +
                                  " comments",
                              style: TextStyle(
                                  color: Color(Constants.whitetext),
                                  fontFamily: Constants.appFont,
                                  fontSize: 16)),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              margin: EdgeInsets.only(right: 20),
                              child: SvgPicture.asset("images/close.svg")),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: commentList.length > 0
                        ? ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: commentList.length,
                            itemBuilder: (context, index) {
                              if (commentList[index].isLike == 1) {
                                commentList[index].showwhite = false;
                                commentList[index].showred = true;
                              } else {
                                commentList[index].showwhite = true;
                                commentList[index].showred = false;
                              }
                              return Container(
                                margin: EdgeInsets.only(
                                    left: 10, top: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 10, bottom: 10),
                                        child: CachedNetworkImage(
                                          alignment: Alignment.center,
                                          imageUrl: commentList[index]
                                                  .user!
                                                  .imagePath! +
                                              commentList[index].user!.image!,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  CircleAvatar(
                                            radius: 15,
                                            backgroundColor: Color(0xFF36446b),
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundImage: imageProvider,
                                            ),
                                          ),
                                          placeholder: (context, url) => CustomLoader(),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                  "images/no_image.png"),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: ListView(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 10, bottom: 0),
                                              color: Colors.transparent,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    commentList[index]
                                                        .user!
                                                        .name!,
                                                    style: TextStyle(
                                                        color: Color(
                                                            Constants.greytext),
                                                        fontSize: 14,
                                                        fontFamily:
                                                            Constants.appFont),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                color: Colors.transparent,
                                                child: Text(
                                                  commentList[index].comment!,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Color(
                                                          Constants.whitetext),
                                                      fontSize: 14,
                                                      fontFamily:
                                                          Constants.appFont),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                          margin: EdgeInsets.only(
                                              left: 10, top: 10),
                                          child: ListView(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  mystate(() {
                                                    commentList[index]
                                                        .showwhite = true;
                                                    commentList[index].showred =
                                                        false;
                                                    Constants.checkNetwork()
                                                        .whenComplete(() =>
                                                            callApiForlikeComment(
                                                                commentList[
                                                                        index]
                                                                    .id,
                                                                context,
                                                                index));
                                                  });
                                                },
                                                child: Visibility(
                                                  visible: commentList[index]
                                                      .showred,
                                                  child: Container(
                                                    child: SvgPicture.asset(
                                                      "images/red_heart.svg",
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  mystate(() {
                                                    commentList[index]
                                                        .showwhite = false;
                                                    commentList[index].showred =
                                                        true;
                                                    Constants.checkNetwork()
                                                        .whenComplete(() =>
                                                            callApiForlikeComment(
                                                                commentList[
                                                                        index]
                                                                    .id,
                                                                context,
                                                                index));
                                                  });
                                                },
                                                child: Visibility(
                                                  visible: commentList[index]
                                                      .showwhite,
                                                  child: Container(
                                                    child: SvgPicture.asset(
                                                      "images/white_heart.svg",
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  commentList[index]
                                                      .likesCount
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color(
                                                          Constants.whitetext),
                                                      fontFamily:
                                                          Constants.appFont,
                                                      fontSize: 14),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          )),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: PopupMenuButton<String>(
                                          color: Color(Constants.conbg),
                                          icon: SvgPicture.asset(
                                            "images/more_menu.svg",
                                            width: 20,
                                            height: 20,
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(18.0))),
                                          offset: Offset(20, 20),
                                          onSelected: choiceAction,
                                          itemBuilder: (BuildContext context) {
                                            selectedCommentId =
                                                commentList[index].id;
                                            removeVideoIndex = videoIndex;
                                            return choices.map((String choice) {
                                              return PopupMenuItem<String>(
                                                value: choice,
                                                child: Text(
                                                  choice,
                                                  style: TextStyle(
                                                      color: Color(
                                                          Constants.whitetext),
                                                      fontSize: 14,
                                                      fontFamily: Constants
                                                          .appFontBold),
                                                ),
                                              );
                                            }).toList();
                                          },
                                        )),
                                  ],
                                ),
                              );
                            },
                          )
                        : Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: ScreenUtil().setHeight(80),
                                margin: const EdgeInsets.only(
                                    top: 10.0,
                                    left: 15.0,
                                    right: 15,
                                    bottom: 0),
                                child: Text(
                                  "No Comments Available !",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: Constants.appFont,
                                      fontSize: 20),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 0, bottom: 0),
                    height: ScreenUtil().setHeight(50),
                    color: Color(0xFF1d1d1d),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: SvgPicture.asset("images/emojis.svg")),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: TextField(
                                autofocus: false,
                                controller: _textCommentController,
                                style: TextStyle(
                                    color: Color(Constants.whitetext),
                                    fontSize: 14,
                                    fontFamily: Constants.appFont),
                                decoration: InputDecoration.collapsed(
                                  hintText: "Type Something...",
                                  hintStyle: TextStyle(
                                      color: Color(Constants.hinttext),
                                      fontSize: 14,
                                      fontFamily: Constants.appFont),
                                  border: InputBorder.none,
                                ),
                                maxLines: 1,
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                              margin: EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () {
                                  if (_textCommentController.text.length > 0) {
                                    updateCommentsCount(
                                        videoId: nearByVidList[index1].id);
                                    Constants.checkNetwork().whenComplete(() =>
                                        callApiForPostComment(
                                            _textCommentController.text,
                                            context,
                                            nearByVidList[index1].id));
                                  }
                                },
                                child:
                                    SvgPicture.asset("images/post_comment.svg"),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  void choiceAction(String choice) {
    if (choice == "Delete Comment") {
      print('delete comment');
      callApiForDeleteComment(selectedCommentId, context);
      removeCommentsCount(videoId: removeVideoIndex);
    } else if (choice == "Report Comment") {
      print('Report Comment');
      callApiForReportCommentReason(selectedCommentId);
    }
  }

  void callApiForDeleteComment(int? id, BuildContext context) {
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData()).deleteComment(id).then((response) {
      final body = json.decode(response!);
      bool? sucess = body['success'];
      print(sucess);
      if (sucess == true) {
        if (mounted) {
          setState(() {
            showSpinner = false;
            var msg = body['msg'];
            Constants.toastMessage(msg);
            Navigator.of(context).pop();
          });
        } else {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage(msg);
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          setState(() {
            showSpinner = false;
            var msg = body['msg'];
            Constants.toastMessage(msg);
            Navigator.of(context).pop();
          });
        } else {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage(msg);
          Navigator.of(context).pop();
        }
      }
    }).catchError((Object obj) {
      Constants.toastMessage(obj.toString());


      setState(() {
        showSpinner = false;
      });
      print("error:$obj");
      print(obj.runtimeType);
    });
  }

  callApiForReportCommentReason(int? commentId) {
    reportReasonData.clear();
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData()).reportReason("Comment").then((response) {
      if (response.success == true) {
        setState(() {
          showSpinner = false;
          reportReasonData.addAll(response.data!);
          openReportBottomSheetComment(commentId);
        });
      } else {
        setState(() {
          showSpinner = false;
          Constants.toastMessage(response.msg!);
        });
      }
    }).catchError((Object obj) {
      print(obj.toString());
      Constants.toastMessage(obj.toString());
      if (mounted)
        setState(() {
          showSpinner = false;
        });
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response!;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('InternalServerError');
          }
          break;
        default:
      }
    });
  }

  void openReportBottomSheet() {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Color(Constants.bgblack),
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter mystate) {
              mystate(() {});
              return Container(
                height: MediaQuery.of(context).size.height * 0.80,
                child: Scaffold(
                  backgroundColor: Color(Constants.bgblack1),
                  bottomNavigationBar: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: ScreenUtil().setHeight(50),
                      color: Color(0xff36446B),
                      alignment: Alignment.center,
                      child: Text(
                        'Submit Report',
                        style: TextStyle(
                            color: Color(Constants.whitetext),
                            fontSize: 15,
                            fontFamily: Constants.appFont),
                      ),
                    ),
                  ),
                  body: Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: ScreenUtil().setHeight(50),
                            color: Color(Constants.bgblack1),
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Reason of Report',
                                    style: TextStyle(
                                        color: Color(Constants.whitetext),
                                        fontSize: 13,
                                        fontFamily: Constants.appFont),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(Icons.close,
                                          color: Colors.white))
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.63,
                            child: ListView(
                              children: <Widget>[
                                SingleChildScrollView(
                                  child: ListView.builder(
                                    itemCount: 20,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    itemBuilder:
                                        (BuildContext context, int? index) {
                                      return InkWell(
                                        onTap: () {},
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                                alignment: Alignment.center,
                                                child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5, right: 10),
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                        margin: EdgeInsets.only(
                                                            left: 2),
                                                        child: Theme(
                                                          data:
                                                              Theme.of(context)
                                                                  .copyWith(
                                                            unselectedWidgetColor:
                                                                Color(Constants
                                                                    .whitetext),
                                                            disabledColor:
                                                                Color(Constants
                                                                    .whitetext),
                                                          ),
                                                          child:
                                                              Transform.scale(
                                                            scale: 1.2,
                                                            child: Radio<int>(
                                                              activeColor: Color(
                                                                  Constants
                                                                      .whitetext),
                                                              value: index!,
                                                              groupValue: index,
                                                              onChanged:
                                                                  (int? value) {
                                                                setState(() {
                                                                  index = value;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        )))),
                                            Text(
                                              "Childs Abuse Content",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Color(
                                                      Constants.whitetext),
                                                  fontSize: 14,
                                                  fontFamily:
                                                      Constants.appFont),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }));
  }

  void openReportBottomSheetComment(int? commentId) {
    int? value;
    int? reasonId;
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Color(Constants.bgblack),
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter mystate) {
              mystate(() {});
              return Container(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Scaffold(
                  backgroundColor: Color(Constants.bgblack1),
                  bottomNavigationBar: InkWell(
                    onTap: reasonId == null
                        ? null
                        : () {
                            Constants.checkNetwork().whenComplete(() =>
                                callApiForReportComment(commentId, reasonId));
                          },
                    child: Container(
                      height: ScreenUtil().setHeight(50),
                      color: Color(0xff36446B),
                      alignment: Alignment.center,
                      child: Text(
                        'Submit Report',
                        style: TextStyle(
                            color: Color(Constants.whitetext),
                            fontSize: 15,
                            fontFamily: Constants.appFont),
                      ),
                    ),
                  ),
                  body: Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: ScreenUtil().setHeight(50),
                            color: Color(Constants.bgblack1),
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Reason of Report',
                                    style: TextStyle(
                                        color: Color(Constants.whitetext),
                                        fontSize: 13,
                                        fontFamily: Constants.appFont),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(Icons.close,
                                          color: Colors.white))
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.50,
                            child: ListView(
                              children: <Widget>[
                                SingleChildScrollView(
                                  child: ListView.builder(
                                    itemCount: reportReasonData.length,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Theme(
                                        data: ThemeData(
                                          unselectedWidgetColor:
                                              Color(Constants.whitetext),
                                        ),
                                        child: RadioListTile(
                                          value: index,
                                          groupValue: value,
                                          onChanged: (dynamic val) =>
                                              mystate(() {
                                            reasonId =
                                                reportReasonData[index].id;
                                            value = val;
                                          }),
                                          title: Text(
                                            reportReasonData[index].reason!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color:
                                                    Color(Constants.whitetext),
                                                fontSize: 14,
                                                fontFamily: Constants.appFont),
                                          ),
                                          activeColor:
                                              Color(Constants.whitetext),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }));
  }

  callApiForReportComment(commentId, reportId) {
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData())
        .reportComment(commentId.toString(), reportId.toString())
        .then((response) {
      final body = json.decode(response!);
      bool? success = body['success'];
      if (success == true) {
        setState(() {
          showSpinner = false;
          var msg = body['msg'];

          Constants.toastMessage('$msg');
          Navigator.pop(context);
        });
      } else {
        setState(() {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage('$msg');
          Navigator.pop(context);
        });
      }
    }).catchError((Object obj) {
      print(obj.toString());
      Constants.toastMessage(obj.toString());
      if (mounted)
        setState(() {
          showSpinner = false;
        });
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response!;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('InternalServerError');
          }
          break;
        default:
      }
    });
  }

  callApiForBlockUser(int? userid) {
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData())
        .blockuser(userid.toString(), "User")
        .then((response) {
      final body = json.decode(response!);
      bool? sucess = body['success'];
      print(sucess);

      if (sucess == true) {
        setState(() {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage(msg.toString());


          Constants.checkNetwork().whenComplete(() => callApiForNearByVideo());
        });
      } else {
        setState(() {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage(msg.toString());

        });
      }
    }).catchError((Object obj) {
      Constants.toastMessage(obj.toString());



      setState(() {
        showSpinner = false;
      });
      print("error:$obj");
      print(obj.runtimeType);
    });
  }

  void callApiForSavevideo(int? id) {
    print("likeid:$id");
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData()).savevideo(id).then((response) {
      final body = json.decode(response!);
      bool? sucess = body['success'];
      print(sucess);
      if (sucess == true) {
        setState(() {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage(msg.toString());


        });
      } else {
        setState(() {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage(msg.toString());

        });
      }
    }).catchError((Object obj) {
      Constants.toastMessage(obj.toString());


      setState(() {
        showSpinner = false;
      });
      print("error:$obj");
      print(obj.runtimeType);
    });
  }

  void callApiForlikeComment(int? id, BuildContext context, int index) {
    print("likeid:$id");
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData()).likecomment(id).then((response) {
      final body = json.decode(response!);
      bool? sucess = body['success'];
      print(sucess);
      if (sucess == true) {
        setState(() {
          showSpinner = false;

          Navigator.pop(context);
        });
      } else {
        setState(() {
          showSpinner = false;

        });
      }
    }).catchError((Object obj) {
      Constants.toastMessage(obj.toString());


      setState(() {
        showSpinner = false;
      });
      print("error:$obj");
      print(obj.runtimeType);
    });
  }

  callApiForPostComment(String comment, BuildContext context, int? id) {
    print("likeid:$id");
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData())
        .postcomment(id.toString(), comment)
        .then((response) {
      final body = json.decode(response!);
      bool? sucess = body['success'];
      print(sucess);
      if (sucess == true) {
        setState(() {
          showSpinner = false;

          Navigator.pop(context);

          Constants.checkNetwork().whenComplete(() => callApiForNearByVideo());
        });
      } else {
        setState(() {
          showSpinner = false;

        });
      }
    }).catchError((Object obj) {
      Constants.toastMessage(obj.toString());


      setState(() {
        showSpinner = false;
      });
      print("error:$obj");
      print(obj.runtimeType);
    });
  }

  void callApiForFollowRequest(int? userId, int? videoId) {
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData()).followRequest(userId).then((response) {
      final body = json.decode(response!);
      bool? success = body['success'];
      if (success == true) {
        setState(() {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage(msg);
          updateFollow(videoId: videoId);
        });
      } else {
        setState(() {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage(msg);
          updateFollow(videoId: videoId);
        });
      }
    }).catchError((Object obj) {
      print(obj.toString());
      Constants.toastMessage(obj.toString());
      if (mounted)
        setState(() {
          showSpinner = false;
        });
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response!;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('InternalServerError');
          }
          break;
        default:
      }
    });
  }

  void callApiForUnFollowRequest(int? userId, int? videoId) {
    setState(() {
      showSpinner = true;
    });
    RestClient(ApiHeader().dioData()).unFollowRequest(userId).then((response) {
      final body = json.decode(response!);
      bool? success = body['success'];
      if (success == true) {
        setState(() {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage(msg);
          updateUnFollow(videoId: videoId);

        });
      } else {
        setState(() {
          showSpinner = false;
          var msg = body['msg'];
          Constants.toastMessage(msg);
          updateUnFollow(videoId: videoId);
        });
      }
    }).catchError((Object obj) {
      print(obj.toString());
      Constants.toastMessage(obj.toString());
      if (mounted)
        setState(() {
          showSpinner = false;
        });
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response!;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('$responsecode');
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('InternalServerError');
          }
          break;
        default:
      }
    });
  }

  void sharePost(int index) {
    setState(() {
      showSpinner = true;
    });
    Share.share(nearByVidList[index].imagePath! + nearByVidList[index].video!)
        .whenComplete(() {
      setState(() {
        showSpinner = false;
      });
    });
  }

  void updateLike({int? videoId, String? totalLikes, bool? videoLike}) {
    final tile = this.nearByVidList.firstWhere((item) => item.id == videoId);
    setState(() {
      tile.likeCount = totalLikes;
      tile.isLike = videoLike;
    });
  }

  void updateFollow({int? videoId}) {
    final tile = this.nearByVidList.firstWhere((item) => item.id == videoId);
    setState(() {
      tile.user!.isFollowing = 1;
    });
  }

  void updateUnFollow({int? videoId}) {
    final tile = this.nearByVidList.firstWhere((item) => item.id == videoId);
    setState(() {
      tile.user!.isFollowing = 0;
    });
  }

  updateCommentsCount({
    int? videoId,
  }) {
    final tile = this.nearByVidList.firstWhere((item) => item.id == videoId);
    setState(() {
      int commentCount = int.parse(tile.commentCount.toString());
      commentCount += 1;
      tile.commentCount = commentCount.toString();
    });
  }

  removeCommentsCount({
    int? videoId,
  }) {
    final tile = this.nearByVidList.firstWhere((item) => item.id == videoId);
    setState(() {
      int commentCount = int.parse(tile.commentCount.toString());
      commentCount -= 1;
      tile.commentCount = commentCount.toString();
    });
  }

  Future<bool> _onWillPop() async {
    return true;
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String? videoUrl;
  final int? videoId;

  VideoPlayerItem({Key? key, this.videoUrl, this.videoId}) : super(key: key);

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _videoController;
  bool isShowPlaying = false;
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.network(widget.videoUrl!)
      ..initialize().then((value) => {
            setState(() {
              isShowPlaying = false;
              _videoController.play();
            })
          });
    _videoController.setLooping(true);
    _videoController.play();
    callApiForViewVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerItem oldWidget) {
    _videoController.pause();
    super.didUpdateWidget(oldWidget);
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _videoController.pause();
    } else if (state == AppLifecycleState.resumed) {}
  }

  @override
  void dispose() {
    super.dispose();
    _videoController.dispose();
  }

  _hideBar() async {
    Timer(
      Duration(seconds: 2),
      () {
        setState(() {
          _visible = false;
        });
      },
    );
  }

/*  Widget isPlaying() {
    _visible = true;
    return Visibility(
      visible: _visible,
      child: _videoController.value.volume > 0
          ? Container(child: SvgPicture.asset('images/ic_mute.svg'),)
          : Icon(
              Icons.play_arrow,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
    );
  }*/

  void callApiForViewVideo() {
    RestClient(ApiHeader().dioData())
        .viewVideo(widget.videoId)
        .then((response) {
      print(response);
    }).catchError((Object obj) {
      print("error:$obj");
      print(obj.runtimeType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {


          _visible = true;
          _hideBar();
          _videoController.value.isPlaying
              ? _videoController.pause()
              : _videoController.play();
        });
      },
      child: Stack(
        children: <Widget>[
         VideoPlayer(_videoController),
          Align(
            alignment: Alignment.center,
            child: Center(
              child: Visibility(
                  visible: _visible,
                  child: _videoController.value.isPlaying
                      ? MuteIconWidget(isMute: true)
                      : MuteIconWidget(isMute: false)),
            ),
          )
        ],
      ),
    );
  }
}
