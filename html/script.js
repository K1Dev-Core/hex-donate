window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'openUI') {
        openDonationUI(data.data);
    } else if (data.type === 'closeUI') {
        closeDonationUI();
    } else if (data.type === 'updateProgress') {
        updateDonationProgress(data.data);
    } else if (data.type === 'showTextUI') {
        showTextUI(data.data);
    } else if (data.type === 'hideTextUI') {
        hideTextUI();
    } else if (data.type === 'showNotification') {
        showNotification(data.data.message, data.data.type);
    }
});

function openDonationUI(data) {
    document.querySelector('.bg').style.display = 'block';
    
    document.querySelector('.fund-name').textContent = data.pointName;
    document.querySelector('.current-amount').textContent = `฿${data.currentAmount.toLocaleString()}`;
    document.querySelector('.target-amount').textContent = `/ ฿${data.maxAmount.toLocaleString()}`;
    
    const percentage = Math.min((data.currentAmount / data.maxAmount) * 100, 100);
    document.querySelector('.progress-fill').style.width = `${percentage}%`;
    document.querySelector('.fund-percentage').textContent = `${Math.round(percentage)}%`;
    
    const speechText = document.querySelector('.speech-text');
    speechText.innerHTML = '';
    data.speechText.forEach(text => {
        const p = document.createElement('p');
        p.textContent = text;
        speechText.appendChild(p);
    });
    
    const charImg = document.querySelector('.char-img');
    if (charImg && data.characterImage) {
        charImg.src = data.characterImage;
        charImg.alt = "Character";
   
        if (percentage >= 100) {
            charImg.classList.add('colored');
            charImg.style.filter = '';
        } else {
            charImg.classList.remove('colored');
            charImg.style.filter = `grayscale(${100 - percentage}%)`;
        }
    }
    
    updateTopDonators(data.topDonators);
    updateRecentDonations(data.recentDonations);
    
    const isFull = data.currentAmount >= data.maxAmount;
    const donationForm = document.querySelector('.donation-form');
    const donateBtn = document.querySelector('.donate-btn');
    const donationAmount = document.querySelector('.donation-amount');
    
    if (isFull) {
        donationForm.style.display = 'none';
        let fullMessage = document.querySelector('.fund-full-message');
        if (!fullMessage) {
            fullMessage = document.createElement('div');
            fullMessage.className = 'fund-full-message';
            fullMessage.innerHTML = `
                <div class="full-title">กองทุนเต็มแล้ว</div>
                <div class="full-subtitle">ขอบคุณสำหรับการสนับสนุนทุกท่าน</div>
            `;
            fullMessage.style.cssText = `
                text-align: center;
                padding: 1.2em;
                background: linear-gradient(180deg, rgba(255, 199, 0, 0.1) 0%, rgba(255, 153, 0, 0.05) 100%);
                border: 1px solid rgba(255, 199, 0, 0.3);
                color: #FFC700;
                font-family: 'Athiti', sans-serif;
            `;
            
            const fullTitle = fullMessage.querySelector('.full-title');
            fullTitle.style.cssText = `
                font-size: 14px;
                font-weight: 600;
                margin-bottom: 0.3em;
            `;
            
            const fullSubtitle = fullMessage.querySelector('.full-subtitle');
            fullSubtitle.style.cssText = `
                font-size: 12px;
                opacity: 0.8;
            `;
            
            document.querySelector('.donation-right').appendChild(fullMessage);
        }
    } else {
        donationForm.style.display = 'block';
        const fullMessage = document.querySelector('.fund-full-message');
        if (fullMessage) {
            fullMessage.remove();
        }
        initializeDonationSystem();
    }
}

function closeDonationUI() {
    const container = document.querySelector('.donation-container');
    container.classList.add('closing');
    
    setTimeout(() => {
        document.querySelector('.bg').style.display = 'none';
        container.classList.remove('closing');
    }, 400);
}

function updateDonationProgress(data) {
    document.querySelector('.current-amount').textContent = `฿${data.currentAmount.toLocaleString()}`;
    document.querySelector('.target-amount').textContent = `/ ฿${data.maxAmount.toLocaleString()}`;
    
    const percentage = Math.min((data.currentAmount / data.maxAmount) * 100, 100);
    document.querySelector('.progress-fill').style.width = `${percentage}%`;
    document.querySelector('.fund-percentage').textContent = `${Math.round(percentage)}%`;

    const charImg = document.querySelector('.char-img');
    if (charImg) {
        if (percentage >= 100) {
            charImg.classList.add('colored');
            charImg.style.filter = '';
        } else {
            charImg.classList.remove('colored');
            charImg.style.filter = `grayscale(${100 - percentage}%)`;
        }
    }
    
    updateTopDonators(data.topDonators);
    updateRecentDonations(data.recentDonations);
    
    const isFull = data.currentAmount >= data.maxAmount;
    const donationForm = document.querySelector('.donation-form');
    
    if (isFull) {
        donationForm.style.display = 'none';
        let fullMessage = document.querySelector('.fund-full-message');
        if (!fullMessage) {
            fullMessage = document.createElement('div');
            fullMessage.className = 'fund-full-message';
            fullMessage.innerHTML = `
                <div class="full-title">กองทุนเต็มแล้ว</div>
                <div class="full-subtitle">ขอบคุณสำหรับการสนับสนุนทุกท่าน</div>
            `;
            fullMessage.style.cssText = `
                text-align: center;
                padding: 1.2em;
                background: linear-gradient(180deg, rgba(255, 199, 0, 0.1) 0%, rgba(255, 153, 0, 0.05) 100%);
                border: 1px solid rgba(255, 199, 0, 0.3);
                color: #FFC700;
                font-family: 'Athiti', sans-serif;
            `;
            
            const fullTitle = fullMessage.querySelector('.full-title');
            fullTitle.style.cssText = `
                font-size: 14px;
                font-weight: 600;
                margin-bottom: 0.3em;
            `;
            
            const fullSubtitle = fullMessage.querySelector('.full-subtitle');
            fullSubtitle.style.cssText = `
                font-size: 12px;
                opacity: 0.8;
            `;
            
            document.querySelector('.donation-right').appendChild(fullMessage);
        }
    } else {
        donationForm.style.display = 'block';
        const fullMessage = document.querySelector('.fund-full-message');
        if (fullMessage) {
            fullMessage.remove();
        }
    }
}

function updateTopDonators(topDonators) {
    const tdList = document.querySelector('.td-list');
    tdList.innerHTML = '';
    
    topDonators.forEach((donator, index) => {
        const tdItem = document.createElement('div');
        tdItem.className = 'td-item';
        tdItem.innerHTML = `
            <span class="td-rank">${index + 1}</span>
            <span class="td-name">${donator.playerName}</span>
            <span class="td-amount">฿${donator.totalAmount.toLocaleString()}</span>
        `;
        tdList.appendChild(tdItem);
    });
}

function updateRecentDonations(recentDonations) {
    const rdList = document.querySelector('.rd-list');
    rdList.innerHTML = '';
    
    recentDonations.forEach(donation => {
        const rdItem = document.createElement('div');
        rdItem.className = 'rd-item';
        
        const timeAgo = getTimeAgo(donation.timestamp);
        
        rdItem.innerHTML = `
            <span class="rd-name">${donation.playerName}</span>
            <span class="rd-amount">฿${donation.amount.toLocaleString()}</span>
            <span class="rd-time">${timeAgo}</span>
        `;
        rdList.appendChild(rdItem);
    });
}

function getTimeAgo(timestamp) {
    const now = Math.floor(Date.now() / 1000);
    const diff = now - timestamp;
    
    if (diff < 60) return `${diff} วินาทีที่แล้ว`;
    if (diff < 3600) return `${Math.floor(diff / 60)} นาทีที่แล้ว`;
    if (diff < 86400) return `${Math.floor(diff / 3600)} ชั่วโมงที่แล้ว`;
    return `${Math.floor(diff / 86400)} วันที่แล้ว`;
}

function initializeDonationSystem() {
    const donationAmountInput = document.querySelector('.donation-amount');
    const donateBtn = document.querySelector('.donate-btn');
    
    if (donationAmountInput) {
        donationAmountInput.addEventListener('input', function(e) {
            let value = e.target.value;
            value = value.replace(/[^0-9]/g, '');
            if (value === '' || parseInt(value) <= 0) {
                value = '';
            }
            e.target.value = value;
        });
        
        donationAmountInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                handleDonation();
            }
        });
        
        donationAmountInput.addEventListener('paste', function(e) {
            e.preventDefault();
            let paste = (e.clipboardData || window.clipboardData).getData('text');
            paste = paste.replace(/[^0-9]/g, '');
            if (paste && parseInt(paste) > 0) {
                this.value = paste;
            }
        });
    }
    
    if (donateBtn) {
        donateBtn.addEventListener('click', handleDonation);
    }
}

function handleDonation() {
    const amountInput = document.querySelector('.donation-amount');
    const amount = parseInt(amountInput.value);
    
    if (!amount || amount <= 0) {
        showNotification('กรุณาใส่จำนวนเงินที่ถูกต้อง', 'error');
        return;
    }
    
    showDonationAnimation();
    
    fetch(`https://${GetParentResourceName()}/makeDonation`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            amount: amount
        })
    }).then(() => {
        amountInput.value = '';
    }).catch(() => {
        const donateBtn = document.querySelector('.donate-btn');
        donateBtn.textContent = 'บริจาค';
        donateBtn.disabled = false;
        showNotification('เกิดข้อผิดพลาดในการบริจาค', 'error');
    });
}

function showDonationAnimation() {
    const donateBtn = document.querySelector('.donate-btn');
    const originalText = donateBtn.textContent;
    
    donateBtn.textContent = 'กำลังบริจาค...';
    donateBtn.style.background = 'linear-gradient(180deg, rgba(255, 199, 0, 0.4) 0%, rgba(255, 153, 0, 0.3) 100%)';
    donateBtn.disabled = true;
    
    setTimeout(() => {
        donateBtn.textContent = originalText;
        donateBtn.style.background = 'linear-gradient(180deg, rgba(255, 199, 0, 0.2) 0%, rgba(255, 153, 0, 0.1) 100%)';
        donateBtn.disabled = false;
    }, 1500);
}

let notificationQueue = [];

function showNotification(message, type) {
    const notification = document.createElement('div');
    notification.className = `notification ${type || 'info'}`;
    notification.textContent = message;
    
    notification.style.cssText = `
        position: fixed;
        bottom: 20px;
        left: 50%;
        transform: translateX(-50%);
        background: rgba(0, 0, 0, 0.69);
        color: white;
        padding: 8px 16px;
        border-radius: 0px;
        font-family: 'Athiti', sans-serif;
        font-size: 14px;
        z-index: 10000;
        opacity: 0;
        transition: all 0.3s ease;
        margin-bottom: 10px;
    `;
    
    notificationQueue.push(notification);
    document.body.appendChild(notification);
    
    updateNotificationPositions();
    
    setTimeout(() => {
        notification.style.opacity = '1';
    }, 100);
    
    setTimeout(() => {
        notification.style.opacity = '0';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
            const index = notificationQueue.indexOf(notification);
            if (index > -1) {
                notificationQueue.splice(index, 1);
            }
            updateNotificationPositions();
        }, 300);
    }, 3000);
}

function updateNotificationPositions() {
    notificationQueue.forEach((notification, index) => {
        const bottomPosition = 20 + (index * 50);
        notification.style.bottom = `${bottomPosition}px`;
    });
}

function showTextUI(data) {
    const textUI = document.createElement('div');
    textUI.id = 'textui-container';
    textUI.innerHTML = `
        <div class="textui-box">
            <div class="textui-content">
                <span class="textui-press">กด</span>
                <span class="textui-key">${data.key}</span>
                <span class="textui-action">เพื่อบริจาค</span>
            </div>
            
        </div>
    `;
    
    document.body.appendChild(textUI);
}

function hideTextUI() {
    const textUI = document.getElementById('textui-container');
    if (textUI) {
        const textuiBox = textUI.querySelector('.textui-box');
        if (textuiBox) {
            textuiBox.classList.add('hiding');
            setTimeout(() => {
                textUI.remove();
            }, 200);
        } else {
            textUI.remove();
        }
    }
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeDonation`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }
});

function closeDonationUI() {
    const container = document.querySelector('.donation-container');
    container.classList.add('closing');
    
    setTimeout(() => {
        document.querySelector('.bg').style.display = 'none';
        container.classList.remove('closing');
    }, 400);
}