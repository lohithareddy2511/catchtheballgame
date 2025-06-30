function catchTheBallGame
    % Initialize figure
    f = figure('Name', 'Catch the Ball Game', ...
               'WindowButtonMotionFcn', @moveBasketWithCursor, ...
               'Color', [0.1 0.1 0.1], ...
               'MenuBar', 'none', ...
               'ToolBar', 'none', ...
               'NumberTitle', 'off', ...
               'Resize', 'off', ...
               'Position', [400, 100, 600, 700]);

    axis([0 100 0 100]);
    axis manual off
    hold on;

    % Simulated gradient background
    for i = 1:100
        fill([0 100 100 0], [i-1 i-1 i i], [0.1+i/200 0.1+i/200 0.2+i/200], 'EdgeColor', 'none');
    end

    % Basket parameters
    basket.width = 15;
    basket.height = 3;
    basket.x = 45;
    basket.y = 5;
    basket.obj = rectangle('Position', [basket.x, basket.y, basket.width, basket.height], ...
                           'Curvature', [0.2, 0.2], ...
                           'FaceColor', [0 0.5 1], ...
                           'EdgeColor', 'w', ...
                           'LineWidth', 1.5);

    % Ball parameters
    ball.radius = 3;
    ball.x = randi([10, 90]);
    ball.y = 100;
    ball.dy = 2;
    ball.obj = rectangle('Position', [ball.x, ball.y, ball.radius, ball.radius], ...
                         'Curvature', [1, 1], ...
                         'FaceColor', [1 0.3 0.3], ...
                         'EdgeColor', 'w');

    % Score
    score = 0;
    scoreText = text(50, 95, ['Score: ', num2str(score)], ...
                     'Color', 'w', ...
                     'FontSize', 16, ...
                     'FontWeight', 'bold', ...
                     'HorizontalAlignment', 'center');

    % Game Over Text
    gameOverText = text(50, 50, '', ...
                        'Color', 'w', ...
                        'FontSize', 24, ...
                        'FontWeight', 'bold', ...
                        'HorizontalAlignment', 'center', ...
                        'Visible', 'off');

    % Restart Button
    uicontrol('Style', 'pushbutton', ...
              'String', 'Restart', ...
              'FontSize', 12, ...
              'FontWeight', 'bold', ...
              'Position', [500, 640, 80, 30], ...
              'Callback', @restartGame, ...
              'BackgroundColor', [0.2 0.6 1], ...
              'ForegroundColor', 'w');

    % Timer for game loop
    t = timer('ExecutionMode', 'fixedRate', ...
              'Period', 0.03, ...
              'TimerFcn', @updateGame);
    start(t);

    % ==== Nested Functions ====

    function updateGame(~, ~)
        % Move ball
        ball.y = ball.y - ball.dy;
        set(ball.obj, 'Position', [ball.x, ball.y, ball.radius, ball.radius]);

        % Check collision
        if ball.y <= (basket.y + basket.height) && ...
           ball.x + ball.radius > basket.x && ...
           ball.x < basket.x + basket.width
            score = score + 1;
            set(scoreText, 'String', ['Score: ', num2str(score)]);
            resetBall();
        elseif ball.y <= 0
            stop(t);  % Stop but don't delete
            set(gameOverText, 'String', 'Game Over', 'Visible', 'on');
        end
    end

    function resetBall()
        ball.x = randi([10, 90]);
        ball.y = 100;
        set(ball.obj, 'Position', [ball.x, ball.y, ball.radius, ball.radius]);
    end

    function moveBasketWithCursor(~, ~)
        cp = get(gca, 'CurrentPoint');
        cursorX = cp(1,1);
        basket.x = max(0, min(cursorX - basket.width/2, 100 - basket.width));
        set(basket.obj, 'Position', [basket.x, basket.y, basket.width, basket.height]);
    end

    function restartGame(~, ~)
        % Reset state
        score = 0;
        set(scoreText, 'String', ['Score: ', num2str(score)]);
        resetBall();
        set(gameOverText, 'Visible', 'off');

        % Restart timer if not already running
        if strcmp(t.Running, 'off')
            start(t);
        end
    end

    % Clean up timer on figure close
    set(f, 'CloseRequestFcn', @onClose);

    function onClose(~, ~)
        if isvalid(t)
            stop(t);
            delete(t);
        end
        delete(f);
    end
end
