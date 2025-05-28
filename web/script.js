// Apple Music Web 模拟系统
class AppleMusicApp {
    constructor() {
        this.currentUser = null;
        this.currentSong = null;
        this.isPlaying = false;
        this.currentTime = 0;
        this.duration = 180;
        this.volume = 0.7;
        this.songs = this.initializeSongs();
        this.playlists = this.initializePlaylists();
        this.audioElement = null;
        
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.showPage('login');
        this.initializeAudio();
    }

    initializeAudio() {
        this.audioElement = document.getElementById('audioPlayer');
        if (this.audioElement) {
            this.audioElement.volume = this.volume;
        }
    }

    setupEventListeners() {
        const loginForm = document.getElementById('loginForm');
        if (loginForm) {
            loginForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.handleLogin();
            });
        }

        const twofaForm = document.getElementById('twofaForm');
        if (twofaForm) {
            twofaForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.handleTwoFA();
            });
        }

        const backToLoginBtn = document.getElementById('backToLogin');
        if (backToLoginBtn) {
            backToLoginBtn.addEventListener('click', () => {
                this.showPage('login');
            });
        }

        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.addEventListener('click', (e) => {
                this.switchTab(e.target.dataset.tab);
            });
        });

        const searchBar = document.getElementById('searchBar');
        if (searchBar) {
            searchBar.addEventListener('input', (e) => {
                this.handleSearch(e.target.value);
            });
        }

        this.setupPlayerControls();
        this.setupCodeInputs();
    }

    setupPlayerControls() {
        const prevBtn = document.getElementById('prevBtn');
        const playBtn = document.getElementById('playBtn');
        const nextBtn = document.getElementById('nextBtn');

        if (prevBtn) prevBtn.addEventListener('click', () => this.prevSong());
        if (playBtn) playBtn.addEventListener('click', () => this.togglePlay());
        if (nextBtn) nextBtn.addEventListener('click', () => this.nextSong());
    }

    setupCodeInputs() {
        const codeInputs = document.querySelectorAll('.code-input');
        codeInputs.forEach((input, index) => {
            input.addEventListener('input', (e) => {
                if (e.target.value.length === 1 && index < codeInputs.length - 1) {
                    codeInputs[index + 1].focus();
                }
            });
            
            input.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace' && e.target.value === '' && index > 0) {
                    codeInputs[index - 1].focus();
                }
            });
        });
    }

    async handleLogin() {
        const appleId = document.getElementById('appleId').value;
        const password = document.getElementById('password').value;
        const loginBtn = document.querySelector('#loginForm .btn-primary');
        
        const originalText = loginBtn.textContent;
        loginBtn.innerHTML = '<span class="loading"></span> 验证中...';
        loginBtn.disabled = true;

        await this.delay(1500);

        const user = this.validateUser(appleId, password);
        
        if (user) {
            this.currentUser = user;
            this.showSuccessMessage('Apple ID 验证成功！');
            await this.delay(1000);
            this.showPage('twofa');
            document.getElementById('twofaAppleId').textContent = this.maskAppleId(appleId);
        } else {
            this.showErrorMessage('Apple ID 或密码错误，请重试');
            loginBtn.textContent = originalText;
            loginBtn.disabled = false;
        }
    }

    async handleTwoFA() {
        const codeInputs = document.querySelectorAll('.code-input');
        const code = Array.from(codeInputs).map(input => input.value).join('');
        const verifyBtn = document.querySelector('#twofaForm .btn-primary');
        
        if (code.length !== 6) {
            this.showErrorMessage('请输入完整的6位验证码');
            return;
        }

        const originalText = verifyBtn.textContent;
        verifyBtn.innerHTML = '<span class="loading"></span> 验证中...';
        verifyBtn.disabled = true;

        await this.delay(2000);

        if (code === '123456') {
            this.showSuccessMessage('验证成功！正在登录...');
            await this.delay(1000);
            this.showPage('music');
            this.initializeMusicPage();
        } else {
            this.showErrorMessage('验证码错误，请重试');
            verifyBtn.textContent = originalText;
            verifyBtn.disabled = false;
            codeInputs.forEach(input => input.value = '');
            codeInputs[0].focus();
        }
    }

    validateUser(appleId, password) {
        const users = [
            {
                id: 'music.lover@icloud.com',
                password: 'Music2024!',
                name: '音乐爱好者',
                phone: '+86 138****8888',
                membership: 'Apple Music 会员',
                avatar: '🎵'
            },
            {
                id: '+86 139****9999',
                password: 'Apple123!',
                name: '普通用户',
                email: 'user@icloud.com',
                membership: '免费用户',
                avatar: '👤'
            }
        ];

        return users.find(user => 
            user.id === appleId && user.password === password
        );
    }

    initializeMusicPage() {
        this.updateUserInfo();
        this.loadTrendingSongs();
        this.loadPlaylists();
        this.switchTab('trending');
    }

    updateUserInfo() {
        const userInfoElement = document.querySelector('.user-info');
        if (userInfoElement && this.currentUser) {
            userInfoElement.textContent = `${this.currentUser.avatar} ${this.currentUser.name}`;
        }
    }

    loadTrendingSongs() {
        const container = document.getElementById('trendingSongs');
        if (!container) return;

        container.innerHTML = '';
        this.songs.forEach((song, index) => {
            const songCard = this.createSongCard(song, index);
            container.appendChild(songCard);
        });
    }

    loadPlaylists() {
        const container = document.getElementById('playlistSongs');
        if (!container) return;

        container.innerHTML = '';
        this.playlists.forEach((playlist, index) => {
            const playlistCard = this.createPlaylistCard(playlist, index);
            container.appendChild(playlistCard);
        });
    }

    createSongCard(song, index) {
        const card = document.createElement('div');
        card.className = 'song-card';
        card.innerHTML = `
            <div class="song-info">
                <div class="song-cover">${song.cover}</div>
                <div class="song-details">
                    <h4>${song.title}</h4>
                    <p>${song.artist} • ${song.album}</p>
                </div>
            </div>
        `;
        
        card.addEventListener('click', () => {
            this.playSong(song, index);
        });
        
        return card;
    }

    createPlaylistCard(playlist, index) {
        const card = document.createElement('div');
        card.className = 'song-card';
        card.innerHTML = `
            <div class="song-info">
                <div class="song-cover">${playlist.cover}</div>
                <div class="song-details">
                    <h4>${playlist.name}</h4>
                    <p>${playlist.count} 首歌曲 • ${playlist.creator}</p>
                </div>
            </div>
        `;
        
        return card;
    }

    playSong(song, index) {
        this.currentSong = { ...song, index };
        this.updateCurrentSongDisplay();
        this.isPlaying = true;
        this.updatePlayButton();
        this.simulatePlayback();
        this.showSuccessMessage(`正在播放: ${song.title}`);
    }

    simulatePlayback() {
        if (this.playbackInterval) {
            clearInterval(this.playbackInterval);
        }
        
        this.currentTime = 0;
        this.playbackInterval = setInterval(() => {
            if (this.isPlaying) {
                this.currentTime += 1;
                this.updateProgress();
                
                if (this.currentTime >= this.duration) {
                    this.nextSong();
                }
            }
        }, 1000);
    }

    togglePlay() {
        this.isPlaying = !this.isPlaying;
        this.updatePlayButton();
    }

    prevSong() {
        if (this.currentSong && this.currentSong.index > 0) {
            const prevIndex = this.currentSong.index - 1;
            this.playSong(this.songs[prevIndex], prevIndex);
        }
    }

    nextSong() {
        if (this.currentSong && this.currentSong.index < this.songs.length - 1) {
            const nextIndex = this.currentSong.index + 1;
            this.playSong(this.songs[nextIndex], nextIndex);
        } else {
            this.playSong(this.songs[0], 0);
        }
    }

    updateCurrentSongDisplay() {
        const currentCover = document.querySelector('.current-cover');
        const currentTitle = document.querySelector('.current-info h4');
        const currentArtist = document.querySelector('.current-info p');
        
        if (this.currentSong) {
            if (currentCover) currentCover.textContent = this.currentSong.cover;
            if (currentTitle) currentTitle.textContent = this.currentSong.title;
            if (currentArtist) currentArtist.textContent = this.currentSong.artist;
        }
    }

    updatePlayButton() {
        const playBtn = document.getElementById('playBtn');
        if (playBtn) {
            playBtn.textContent = this.isPlaying ? '⏸️' : '▶️';
        }
    }

    updateProgress() {
        const progressFill = document.querySelector('.progress-fill');
        const currentTimeElement = document.querySelector('.current-time');
        const totalTimeElement = document.querySelector('.total-time');
        
        const progress = (this.currentTime / this.duration) * 100;
        
        if (progressFill) {
            progressFill.style.width = `${progress}%`;
        }
        
        if (currentTimeElement) {
            currentTimeElement.textContent = this.formatTime(this.currentTime);
        }
        
        if (totalTimeElement) {
            totalTimeElement.textContent = this.formatTime(this.duration);
        }
    }

    switchTab(tabName) {
        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.classList.remove('active');
        });
        
        const activeTab = document.querySelector(`[data-tab="${tabName}"]`);
        if (activeTab) {
            activeTab.classList.add('active');
        }
        
        document.querySelectorAll('.content-section').forEach(section => {
            section.style.display = 'none';
        });
        
        const activeSection = document.getElementById(`${tabName}Section`);
        if (activeSection) {
            activeSection.style.display = 'block';
        }
    }

    handleSearch(query) {
        if (!query.trim()) {
            this.loadTrendingSongs();
            return;
        }
        
        const filteredSongs = this.songs.filter(song => 
            song.title.toLowerCase().includes(query.toLowerCase()) ||
            song.artist.toLowerCase().includes(query.toLowerCase()) ||
            song.album.toLowerCase().includes(query.toLowerCase())
        );
        
        const container = document.getElementById('searchResults');
        if (container) {
            container.innerHTML = '';
            
            if (filteredSongs.length > 0) {
                filteredSongs.forEach((song, index) => {
                    const songCard = this.createSongCard(song, index);
                    container.appendChild(songCard);
                });
            } else {
                container.innerHTML = '<p style="color: white; text-align: center; padding: 20px;">未找到相关歌曲</p>';
            }
        }
        
        this.switchTab('search');
    }

    showPage(pageName) {
        document.querySelectorAll('.page').forEach(page => {
            page.classList.remove('active');
        });
        
        const targetPage = document.getElementById(`${pageName}Page`);
        if (targetPage) {
            targetPage.classList.add('active');
        }
    }

    showSuccessMessage(message) {
        this.showMessage(message, 'success');
    }

    showErrorMessage(message) {
        this.showMessage(message, 'error');
    }

    showMessage(message, type) {
        const existingMessage = document.querySelector('.success-message, .error-message');
        if (existingMessage) {
            existingMessage.remove();
        }
        
        const messageElement = document.createElement('div');
        messageElement.className = `${type}-message`;
        messageElement.textContent = message;
        
        const activeForm = document.querySelector('.page.active form, .page.active .login-card, .page.active .twofa-card');
        if (activeForm) {
            activeForm.appendChild(messageElement);
            
            setTimeout(() => {
                if (messageElement.parentNode) {
                    messageElement.remove();
                }
            }, 3000);
        }
    }

    maskAppleId(appleId) {
        if (appleId.includes('@')) {
            const [username, domain] = appleId.split('@');
            const maskedUsername = username.substring(0, 2) + '***' + username.substring(username.length - 2);
            return `${maskedUsername}@${domain}`;
        } else {
            return appleId.substring(0, 6) + '****' + appleId.substring(appleId.length - 4);
        }
    }

    formatTime(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    initializeSongs() {
        return [
            {
                title: "Blinding Lights",
                artist: "The Weeknd",
                album: "After Hours",
                cover: "🌟",
                duration: 200
            },
            {
                title: "Shape of You",
                artist: "Ed Sheeran",
                album: "÷ (Divide)",
                cover: "🎵",
                duration: 233
            },
            {
                title: "Someone Like You",
                artist: "Adele",
                album: "21",
                cover: "💝",
                duration: 285
            },
            {
                title: "Bohemian Rhapsody",
                artist: "Queen",
                album: "A Night at the Opera",
                cover: "👑",
                duration: 355
            },
            {
                title: "Hotel California",
                artist: "Eagles",
                album: "Hotel California",
                cover: "🦅",
                duration: 391
            },
            {
                title: "Imagine",
                artist: "John Lennon",
                album: "Imagine",
                cover: "🕊️",
                duration: 183
            }
        ];
    }

    initializePlaylists() {
        return [
            {
                name: "我的最爱",
                cover: "❤️",
                count: 25,
                creator: "我的音乐"
            },
            {
                name: "流行热歌",
                cover: "🔥",
                count: 50,
                creator: "Apple Music"
            },
            {
                name: "经典摇滚",
                cover: "🎸",
                count: 30,
                creator: "摇滚精选"
            },
            {
                name: "轻松爵士",
                cover: "🎷",
                count: 20,
                creator: "爵士时光"
            }
        ];
    }
}

document.addEventListener('DOMContentLoaded', () => {
    window.appleMusicApp = new AppleMusicApp();
});

window.AppleMusicApp = AppleMusicApp;