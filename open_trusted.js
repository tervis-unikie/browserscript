// SPDX-FileCopyrightText: 2022-2024 TII (SSRC) and the Ghaf contributors
// SPDX-License-Identifier: Apache-2.0

chrome.contextMenus.create({
    id: "openTrusted",
    title: "Open in trusted browser",
    contexts: ["link"]
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
    if (info.menuItemId === "openTrusted") {
        sendNativeMessage(info.linkUrl);
    }
});

function sendNativeMessage(linkUrl) {
    chrome.runtime.sendNativeMessage('fi.ssrc.open_trusted', { "URL": linkUrl },
        (response) => {
            if (chrome.runtime.lastError) {
                console.error(chrome.runtime.lastError);
            } else {
                console.log("open_trusted:", response);
            }
        });
}
