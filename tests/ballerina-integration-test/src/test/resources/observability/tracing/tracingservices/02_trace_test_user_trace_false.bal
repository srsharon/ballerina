// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/testobserve;
import ballerina/observe;

@http:ServiceConfig {
    basePath:"/echoService"
}
service echoService1 on new http:Listener(9091) {
    resource function resourceOne (http:Caller caller, http:Request clientRequest) {
        int id = 0;
        var spanId = observe:startSpan("uSpanOne");
        if (spanId is int) {
            id = spanId;
        }
        http:Response outResponse = new;
        var response = callNextResource1();
        if (response is http:Response) {
            outResponse.setTextPayload("Hello, World!");
            checkpanic caller->respond(outResponse);
            checkpanic observe:finishSpan(id);
        } else {
            error err = error ("error occurred");
            panic err;
        }
    }

    resource function resourceTwo (http:Caller caller, http:Request clientRequest) {
        http:Response res = new;
        res.setTextPayload("Hello, World 2!");
        checkpanic caller->respond(res);
    }

    resource function getMockTracers(http:Caller caller, http:Request clientRequest) {
        http:Response res = new;
        json returnString = testobserve:getMockTracers();
        res.setJsonPayload(returnString);
        checkpanic caller->respond(res);
    }
}

function callNextResource1() returns (http:Response | error) {
    http:Client httpEndpoint = new("http://localhost:9091/echoService", config = {});
    int spanId = check observe:startSpan("uSpanTwo");
    http:Response resp = check httpEndpoint -> get("/resourceTwo");
    checkpanic observe:finishSpan(spanId);
    return resp;
}
