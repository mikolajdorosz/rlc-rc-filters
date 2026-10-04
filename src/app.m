function app()
    defaults = struct( ...
        'type', 'FDP', ...
        'plot', 'Cha-ka a/f-cz', ...
        'R', 1260, ...
        'L', 0.63, ...
        'C', 1e-6 ...
    );
    audioPlayerRLC = []; audioPlayerRC  = [];

    fig = uifigure('Name','RLC Filter GUI', 'Position',[0 0 1500 780]);

    ax = cell(1,4);
    ax{1} = axes(fig, 'Position', [0.325 0.575 0.325 0.375]);
    ax{2} = axes(fig, 'Position', [0.675 0.575 0.325 0.375]);
    ax{3} = axes(fig, 'Position', [0.325 0.075 0.325 0.375]);
    ax{4} = axes(fig, 'Position', [0.675 0.075 0.325 0.375]);

    containerPanel = uipanel(fig,'Position',[5 5 440 770]);
    controlPanel   = uipanel(containerPanel,'Title','Kontrolki','Position',[5 465 430 300]);
    displayRLCPanel = uipanel(containerPanel,'Title','Panel RLC','Position',[5 235 430 230]);
    displayRCPanel  = uipanel(containerPanel,'Title','Panel RC','Position',[5 175 430 60]);

    playRLCBtn  = createButton(controlPanel,'RLC ▶',[10 230 60 30], @playAudioRLC, 'off');
    pauseRLCBtn = createButton(controlPanel,'RLC ⏸',[80 230 60 30], @pauseAudioRLC, 'off');
    playRCBtn   = createButton(controlPanel,'RC ▶',[150 230 60 30], @playAudioRC, 'off');
    pauseRCBtn  = createButton(controlPanel,'RC ⏸',[220 230 60 30], @pauseAudioRC, 'off');

    typeDropdown = createDropdown(controlPanel,'Typ filtra:',[10 170],{'FDP','FGP','FPP'}, defaults.type, @updatePlots);
    plotDropdown = createDropdown(controlPanel,'Rodzaj wykresu:',[130 170],{'Cha-ka a/f-cz','Odp czasowa','Audio'}, defaults.plot, @updatePlots);

    ctrlR = createSliderEdit(controlPanel,'R [Ω]:',[10 140],[10 1e4],defaults.R,false,@updatePlots);
    ctrlL = createSliderEdit(controlPanel,'L [H]:',[10 90],[1e-6 10],defaults.L,true,@updatePlots);
    ctrlC = createSliderEdit(controlPanel,'C [F]:',[10 40],[1e-9 1e-4],defaults.C,true,@updatePlots);

    rlcFields = struct();
    rlcFields.w0   = createReadonly(displayRLCPanel,'ω₀ [rad/s]:',[10 170]);
    rlcFields.f0   = createReadonly(displayRLCPanel,'f₀ [Hz]:',[150 170]);
    rlcFields.ksi  = createReadonly(displayRLCPanel,'ζ [-]:',[290 170]);
    rlcFields.w1   = createReadonly(displayRLCPanel,'ω₁ [rad/s]:',[10 120]);
    rlcFields.f1   = createReadonly(displayRLCPanel,'f₁ [Hz]:',[150 120]);
    rlcFields.d    = createReadonly(displayRLCPanel,'d [rad/s]:',[290 120]);
    rlcFields.wc   = createReadonly(displayRLCPanel,'ωc [rad/s]:',[10 70]);
    rlcFields.fc   = createReadonly(displayRLCPanel,'fc [Hz]:',[150 70]);
    rlcFields.wc_1 = createReadonly(displayRLCPanel,'ωc₁ [rad/s]:',[10 70]);
    rlcFields.fc_1 = createReadonly(displayRLCPanel,'fc₁ [Hz]:',[150 70]);
    rlcFields.A    = createReadonly(displayRLCPanel,'A [rad/s]:',[290 70]);
    rlcFields.wc_2 = createReadonly(displayRLCPanel,'ωc₂ [rad/s]:',[10 20]);
    rlcFields.fc_2 = createReadonly(displayRLCPanel,'fc₂ [Hz]:',[150 20]);
    rlcFields.bw   = createReadonly(displayRLCPanel,'bw [Hz]:',[290 20]);

    rcFields = struct();
    rcFields.wc = createReadonly(displayRCPanel,'ωc [rad/s]:',[10 10]);
    rcFields.fc = createReadonly(displayRCPanel,'fc [Hz]:',[150 10]);
    
    updatePlots();

    function updatePlots()
        resetPlots();
        updateReadonlyVisibility(typeDropdown.dropdown.Value);
        R_real = getSliderValue(ctrlR);
        L_real = getSliderValue(ctrlL);
        C_real = getSliderValue(ctrlC);

        paramsRLC = []; paramsRC = [];
        bRLC = []; aRLC = []; bRC = []; aRC = [];

        if strcmp(typeDropdown.dropdown.Value,'FPP')
            [bRLC,aRLC,paramsRLC] = RLC_filter(typeDropdown.dropdown.Value,R_real,L_real,C_real);
        else
            [bRLC,aRLC,paramsRLC] = RLC_filter(typeDropdown.dropdown.Value,R_real,L_real,C_real);
            [bRC,aRC,paramsRC]   = RC_filter(typeDropdown.dropdown.Value,R_real,C_real);
        end

        updateParamFields(paramsRLC, paramsRC);

        switch plotDropdown.dropdown.Value
            case 'Cha-ka a/f-cz'
                freq_res(typeDropdown.dropdown.Value,bRLC,aRLC,paramsRLC,'RLC',ax{1},ax{2});
                freq_res(typeDropdown.dropdown.Value,bRC,aRC,paramsRC,'RC',ax{3},ax{4});
                toggleAudioButtons('off');
            case 'Odp czasowa'
                time_res(bRLC,aRLC,'RLC', paramsRLC ,ax{1},ax{2});
                time_res(bRC,aRC,'RC', paramsRC, ax{3},ax{4});
                toggleAudioButtons('off');
            case 'Audio'
                [audio_outputRLC,fsRLC] = process_audio('audio_input.wav',bRLC,aRLC,ax{1},ax{2});
                audioPlayerRLC = audioplayer(audio_outputRLC,fsRLC);
                playRLCBtn.Enable  = 'on';
                pauseRLCBtn.Enable = 'on';
                if ~strcmp(typeDropdown.dropdown.Value,'FPP')
                    [audio_outputRC,fsRC] = process_audio('audio_input.wav',bRC,aRC,ax{3},ax{4});
                    audioPlayerRC = audioplayer(audio_outputRC,fsRC);
                    playRCBtn.Enable  = 'on';
                    pauseRCBtn.Enable = 'on';
                end
        end
    end
    function updateParamFields(paramsRLC, paramsRC)
        if ~isempty(paramsRC)
            rcFields.wc.field.Text = num2str(paramsRC.wc);
            rcFields.fc.field.Text = num2str(paramsRC.fc);
        end

        rlcFields.w0.field.Text = num2str(paramsRLC.w0);
        rlcFields.f0.field.Text = num2str(paramsRLC.f0);
        rlcFields.ksi.field.Text = num2str(paramsRLC.ksi);
        rlcFields.w1.field.Text = num2str(paramsRLC.w1);
        rlcFields.f1.field.Text = num2str(paramsRLC.f1);
        rlcFields.d.field.Text  = num2str(paramsRLC.d);
        rlcFields.A.field.Text  = num2str(paramsRLC.A);

        if strcmp(typeDropdown.dropdown.Value,'FPP')
            rlcFields.wc_1.field.Text = num2str(paramsRLC.wc_1);
            rlcFields.fc_1.field.Text = num2str(paramsRLC.fc_1);
            rlcFields.wc_2.field.Text = num2str(paramsRLC.wc_2);
            rlcFields.fc_2.field.Text = num2str(paramsRLC.fc_2);
            rlcFields.bw.field.Text   = num2str(paramsRLC.bw);
        else
            rlcFields.wc.field.Text = num2str(paramsRLC.wc);
            rlcFields.fc.field.Text = num2str(paramsRLC.fc);
        end
    end
    function playAudioRLC(), playAudio(audioPlayerRLC); end
    function pauseAudioRLC(), pauseAudio(audioPlayerRLC); end
    function playAudioRC(), playAudio(audioPlayerRC); end
    function pauseAudioRC(), pauseAudio(audioPlayerRC); end
    function playAudio(player)
        if isempty(player) || ~isvalid(player), return; end
        if strcmp(player.Running,'off'), play(player); else, resume(player); end
    end
    function pauseAudio(player)
        if isempty(player) || ~isvalid(player), return; end
        stop(player);
    end
    function resetPlots()
        for k=1:4, cla(ax{k}); end
        pauseAudioRLC(); pauseAudioRC();
        toggleAudioButtons('off');
        rcFields.wc.field.Text = '-';
        rcFields.fc.field.Text = '-';
    end
    function toggleAudioButtons(state)
        playRLCBtn.Enable = state; pauseRLCBtn.Enable = state;
        playRCBtn.Enable  = state; pauseRCBtn.Enable = state;
    end
    function updateReadonlyVisibility(filterType)
        if strcmp(filterType,'FPP')
            toggleReadonly(rlcFields.fc,'off');  toggleReadonly(rlcFields.wc,'off');
            toggleReadonly(rlcFields.wc_1,'on'); toggleReadonly(rlcFields.wc_2,'on');
            toggleReadonly(rlcFields.fc_1,'on'); toggleReadonly(rlcFields.fc_2,'on');
            toggleReadonly(rlcFields.bw,'on');
        else
            toggleReadonly(rlcFields.fc,'on'); toggleReadonly(rlcFields.wc,'on');
            toggleReadonly(rlcFields.wc_1,'off'); toggleReadonly(rlcFields.wc_2,'off');
            toggleReadonly(rlcFields.fc_1,'off'); toggleReadonly(rlcFields.fc_2,'off');
            toggleReadonly(rlcFields.bw,'off');
        end
    end
end

function val = getSliderValue(ctrl)
    val = ctrl.isLog * 0 + ctrl.slider.Value;
    if ctrl.isLog
        val = 10^ctrl.slider.Value;
    end
end
function h = createDropdown(parent,labelText,pos,items,defaultValue,onChange)
    h.label = uilabel(parent, ...
        'Text',labelText, ...
        'FontWeight','bold', ...
        'Position',[pos(1) pos(2)+22 110 18]);
    h.dropdown = uidropdown(parent, ...
        'Items',items, ...
        'Value',defaultValue, ...
        'Position',[pos(1) pos(2) 110 22],...
        'ValueChangedFcn',@(dd,e) onChange());
end
function h = createButton(parent,text,pos,onClick,enableState)
    if nargin<5, enableState='on'; end
    h = uibutton(parent, ...
        'Text',text, ...
        'Position',pos, ...
        'Enable',enableState, ...
        'ButtonPushedFcn',@(btn,e) onClick());
end
function h = createSliderEdit(parent,labelText,pos,limits,initValue,isLog,onChange)
    h.isLog = isLog;
    h.label = uilabel(parent, ...
        'Text',labelText, ...
        'FontWeight','bold', ...
        'Position',[pos(1) pos(2)-10 40 18]);

    if isLog, lims = log10(limits); val = log10(initValue);
    else, lims = limits; val = initValue; end

    h.slider = uislider(parent, ...
        'Limits',lims, ...
        'Value',val, ...
        'Position',[pos(1)+45 pos(2) 300 3]);
    h.edit   = uieditfield(parent,'numeric', ...
        'Limits',limits, ...
        'Value',initValue, ...
        'Position',[pos(1)+360 pos(2)-15 60 22]);

    h.slider.ValueChangingFcn = @(s,e) syncSlider(s,h.edit);
    h.slider.ValueChangedFcn  = @(s,e) syncSlider(s,h.edit);
    h.edit.ValueChangedFcn    = @(f,e) syncEdit(f,h.slider);

    function syncSlider(slider,edit)
        val = slider.Value; if isLog, val = 10^val; end
        val = min(max(val,edit.Limits(1)),edit.Limits(2));
        edit.Value = val; onChange();
    end

    function syncEdit(edit,slider)
        val = edit.Value;
        if isLog
            val = min(max(val,10^slider.Limits(1)),10^slider.Limits(2));
            slider.Value = log10(val);
        else
            val = min(max(val,slider.Limits(1)),slider.Limits(2));
            slider.Value = val;
        end
        onChange();
    end
end
function h = createReadonly(parent,txt,pos)
    h.label = uilabel(parent, ...
        'Text',txt, ...
        'FontWeight','bold', ...
        'Position',[pos(1) pos(2) 65 18]);
    h.field = uilabel(parent, ...
        'Text','-', ...
        'Position',[pos(1)+67 pos(2) 60 22]);
end
function toggleReadonly(h,onOff)
    if isfield(h,'label') && isvalid(h.label), h.label.Visible = onOff; end
    if isfield(h,'field') && isvalid(h.field), h.field.Visible = onOff; end
end
