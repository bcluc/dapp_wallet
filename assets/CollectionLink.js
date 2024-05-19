// test momo:
// NGUYEN VAN A
// 9704 0000 0000 0018
// 03/07
// OTP
// các thông tin đổi để hiện trên Hóa đơn thanh toán: orderInfo, ,amount, orderID,...
// Đổi redirectURL, ipnURL theo trang web của mình

require("dotenv").config();

function payMomo(amount) {
  var accessKey = process.env.MOMO_ACCESS_KEY;
  var secretKey = process.env.MOMO_SECRET_KEY; //key để test // không đổi
  var orderInfo = "pay with MoMo"; // thông tin đơn hàng
  var partnerCode = "MOMO";
  var redirectUrl = process.env.REDIRECT_URL; // Link chuyển hướng tới sau khi thanh toán hóa đơn
  var ipnUrl = process.env.IPN_URL; // trang truy vấn kết quả, để trùng với redirect
  var requestType = "payWithMethod";
  var amount = amount; // Lượng tiền của hóa  <lượng tiền test ko dc cao quá>
  var orderId = partnerCode + new Date().getTime(); // mã Đơn hàng, có thể đổi
  var requestId = orderId;
  var extraData = ""; // đây là data thêm của doanh nghiệp (địa chỉ, mã COD,....)
  var paymentCode = process.env.PAYMENT_CODE;
  var orderGroupId = "";
  var autoCapture = true;
  var lang = "vi"; // ngôn ngữ

  var resultUrl = "";
  // không đụng tới dòng dưới
  var rawSignature =
    "accessKey=" +
    accessKey +
    "&amount=" +
    amount +
    "&extraData=" +
    extraData +
    "&ipnUrl=" +
    ipnUrl +
    "&orderId=" +
    orderId +
    "&orderInfo=" +
    orderInfo +
    "&partnerCode=" +
    partnerCode +
    "&redirectUrl=" +
    redirectUrl +
    "&requestId=" +
    requestId +
    "&requestType=" +
    requestType;
  //puts raw signature
  console.log("--------------------RAW SIGNATURE----------------");
  console.log(rawSignature);
  //chữ ký (signature)
  const crypto = require("crypto");
  var signature = crypto
    .createHmac("sha256", secretKey)
    .update(rawSignature)
    .digest("hex");
  console.log("--------------------SIGNATURE----------------");
  console.log(signature);

  // data gửi đi dưới dạng JSON, gửi tới MoMoEndpoint
  const requestBody = JSON.stringify({
    partnerCode: partnerCode,
    partnerName: "Test",
    storeId: "MomoTestStore",
    requestId: requestId,
    amount: amount,
    orderId: orderId,
    orderInfo: orderInfo,
    redirectUrl: redirectUrl,
    ipnUrl: ipnUrl,
    lang: lang,
    requestType: requestType,
    autoCapture: autoCapture,
    extraData: extraData,
    orderGroupId: orderGroupId,
    signature: signature,
  });
  // tạo object https
  const https = require("https");
  const options = {
    hostname: process.env.MOMO_HOSTNAME,
    port: 443,
    path: "/v2/gateway/api/create",
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Content-Length": Buffer.byteLength(requestBody),
    },
  };
  // hàm nhận response
  callback = function (res) {
    console.log(`Status: ${res.statusCode}`);
    console.log(`Headers: ${JSON.stringify(res.headers)}`);
    res.setEncoding("utf8");
    res.on("data", (body) => {
      console.log("Body: ");
      console.log(body);
      resultUrl = JSON.parse(body).payUrl;
      console.log("resultCode: ");
      console.log(JSON.parse(body).resultCode);
    });
    res.on("end", () => {
      console.log("No more data in response.");
      console.log(resultUrl);
      //return resultUrl;
    });
  };

  // Gửi request
  const req = https.request(options, callback);

  req.on("error", (e) => {
    console.log("Error....");
  });

  //gửi yêu cầu tới momo, nhận lại kết quả trả về
  // Link chuyển hướng tới momo là payUrl, trong phần body của data trả về

  // write data to request body
  //console.log("Sending....");
  req.write(requestBody);
  req.end();
}

// partnerCode	String		Integration information
// requestId	String		Unique ID of each request
// orderId	String		ID of order that needs to be checked.
// lang	String		Language of returned message (vi or en)
// signature	String		Signature to check information. Use Hmac_SHA256 algorithm with data in format:
// accessKey=$accessKey&orderId=$orderId&partnerCode=$partnerCode
// &requestId=$requestId

function checkStatus(orderId) {
  var accessKey = process.env.MOMO_ACCESS_KEY;
  var requestId = orderId;
  var partnerCode = "MOMO";
  var lang = "vi"; // ngôn ngữ
  var rawSignature =
    "accessKey=" +
    accessKey +
    "&orderId=" +
    orderId +
    "&partnerCode=" +
    partnerCode +
    "&requestId=" +
    requestId;

  const crypto = require("crypto");
  var signature = crypto
    .createHmac("sha256", secretKey)
    .update(rawSignature)
    .digest("hex");

  console.log("--------------------SIGNATURE----------------");
  console.log(signature);

  // data gửi đi dưới dạng JSON, gửi tới MoMoEndpoint
  const requestBody = JSON.stringify({
    partnerCode: partnerCode,
    requestId: requestId,
    orderId: orderId,
    lang: lang,
    signature: signature,
  });

  const https = require("https");
  const options = {
    hostname: process.env.MOMO_HOSTNAME,
    port: 443,
    path: "/v2/gateway/api/query",
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Content-Length": Buffer.byteLength(requestBody),
    },
  };

  // hàm nhận response
  callback = function (res) {
    res.setEncoding("utf8");
    res.on("data", (body) => {
      console.log("Body: ");
      console.log(body);
      resultUrl = JSON.parse(body).payUrl;
      console.log("resultCode: ");
      console.log(JSON.parse(body).resultCode);
    });
    res.on("end", () => {
      console.log("No more data in response.");
      console.log(resultUrl);
      //return resultUrl;
    });
  };

  // Gửi request
  const req = https.request(options, callback);

  req.on("error", (e) => {
    console.log("Error....");
  });

  // write data to request body
  console.log("Sending....");
  req.write(requestBody);
  req.end();
}

payMomo(4500);
