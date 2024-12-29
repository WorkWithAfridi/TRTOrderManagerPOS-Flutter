import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, Response;
import 'package:pdf_printer/service/api/api_endpoints.dart';
import 'package:pdf_printer/service/debug/logger.dart';

enum Method { POST, GET, PUT, DELETE, PATCH }

class NetworkController extends GetxController {
  NetworkController() {
    initializeDio();
  }

  String? appLanguage;
  Map<String, dynamic> headers = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };
  Dio? _dio;
  final _authToken = "".obs;

  Future<NetworkController> initializeDio() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndPoints.baseUrl,
        headers: headers,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    initInterceptors();
    return this;
  }

  void setAuthToken({required String token}) {
    // _authToken.value = token;
    // if (_authToken.value.isNotEmpty) {
    //   Get.find<UserVM>().isUserSignedIn.value = true;
    //   updateHeaders(authToken: _authToken.value);
    // }
    // getAppContents();
  }

  void initInterceptors() {
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (requestOptions, handler) {
          logger.d("REQUEST[${requestOptions.method}] => PATH: ${requestOptions.path}"
              "=> REQUEST VALUES: ${requestOptions.queryParameters} => HEADERS: ${requestOptions.headers}");
          return handler.next(requestOptions);
        },
        onResponse: (response, handler) {
          logger.d("RESPONSE[${response.statusCode}] => DATA: ${response.data}");
          return handler.next(response);
        },
        onError: (err, handler) {
          logger.d("Error[${err.response?.statusCode}]");
          return handler.next(err);
        },
      ),
    );
  }

  Future<Response<dynamic>?> request({
    required String url,
    required Method method,
    Map<String, dynamic>? params,
    Map<String, dynamic>? body,
  }) async {
    logger.d("Request URL: $url");
    logger.d("Request Params: ${jsonEncode(params)}");

    try {
      Map<String, dynamic> payload = {
        'url': url,
        'method': method,
        'params': params,
        'body': body,
      };

      Response response = await compute(
        _performHttpRequest,
        payload,
      );

      return response;
    } on SocketException catch (e) {
      logger.e(e);
    } on FormatException catch (e) {
      logger.e(e);
    } on DioException catch (e) {
      if (e.response != null) {
        logger.d(e.response?.data);
        logger.d(e.response?.headers);
        logger.d(e.response?.requestOptions);

        return e.response;
      } else {
        logger.d(e.requestOptions);
        logger.d(e.message);
      }
    } catch (e) {
      logger.e(e);
    }
    return null;
  }

  Future<Response> _performHttpRequest(Map<String, dynamic> data) async {
    final url = data['url'];
    final method = data['method'];
    final params = data['params'];
    final body = data['body'];

    Response response;
    switch (method) {
      case Method.POST:
        response = await _dio!.post(
          url,
          queryParameters: params,
          data: body,
        );
        break;
      case Method.DELETE:
        response = await _dio!.delete(
          url,
          queryParameters: params,
          data: body,
        );
        break;
      case Method.PATCH:
        response = await _dio!.patch(
          url,
          queryParameters: params,
          data: body,
        );
        break;
      case Method.PUT:
        response = await _dio!.put(
          url,
          queryParameters: params,
          data: body,
        );
        break;
      case Method.GET:
        response = await _dio!.get(
          url,
          queryParameters: params,
          data: body,
        );
        break;
      default:
        response = await _dio!.get(
          url,
          queryParameters: params,
          data: body,
        );
        break;
    }
    return response;
  }
}
