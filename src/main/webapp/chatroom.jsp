<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // 캐시 방지
    // 캐시 때문에 여러 번 접속 시 닉네임 입력 팝업이 안 떠서 방지용으로 넣음
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chat Room</title>
    <style>
        .msgArea {
            border: 1px solid #ccc;
            width: 400px;
            height: 300px;
            overflow-y: auto;
            padding: 8px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>

<h2>웹소켓 채팅</h2>

<div class="msgArea"></div>

<input type="text" class="content" placeholder="메시지를 입력하세요">
<button onclick="sendMsg()">보내기</button>
<button onclick="disconnect()">종료</button>

<script>
    const contextPath = "<%= request.getContextPath() %>";

    // 닉네임 nll 방지
    let userId = null;
    while (!userId || userId.trim() === "") {
        userId = prompt("닉네임을 입력하세요");
    }
	
    // 실행하고 싶으면 이 부분 수정
    const wsUrl = "ws://" + location.hostname + ":8080"
        + contextPath + "/chat/"
        + encodeURIComponent(userId);

    console.log("WebSocket URL =", wsUrl);

    let socket = new WebSocket(wsUrl);

    socket.onopen = function () {
        console.log("WebSocket 연결 성공");
    };

    socket.onerror = function (e) {
        console.error("WebSocket 오류:", e);
    };

    socket.onmessage = function (e) {
        let box = document.querySelector(".msgArea");
        let msg = document.createElement("div");
        msg.innerText = e.data;
        box.append(msg);
        box.scrollTop = box.scrollHeight;
    };

    // 메시지 보내기
    function sendMsg() {
        let input = document.querySelector('.content');
        let msg = input.value.trim();
        if (msg !== "") {
            socket.send(msg);
            input.value = "";
        }
    }

    // 종료
    function disconnect() {
        if (socket && socket.readyState === WebSocket.OPEN) {
            socket.close();
            alert("채팅을 종료합니다.");
        }
    }
</script>

</body>
</html>
