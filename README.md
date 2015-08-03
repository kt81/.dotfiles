.config
=======

環境構築用。zshrcはマイナビニュースの『漢のzsh』から頂戴したのほぼまんま

    cd ~
    
    git clone https://github.com/kt81/.config.git
    .common_conf/setup.sh
    
    # chshもやってなければやる
    chsh -s /bin/zsh
    
    # optional
    vim .zshrc.mine
