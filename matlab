% خواندن داده‌ها از فایل اکسل
filename = 'data.xlsx'; % 
data = readtable(filename); %

فایل: t.m
clear all;
clc;

% هزینه‌ها
cost_per_cpu = 1;
cost_per_ram = 0.1;
cost_per_bandwidth = 0.05;
cost_per_time = 0.2;

% تعریف سناریوها
scenarios = {
    struct('name', 'Low Users', 'num_vip', 5, 'num_normal', 5, 'resources', struct('cpu', 2, 'ram', 20, 'bandwidth', 60)), ...
    struct('name', 'High Users', 'num_vip', 20, 'num_normal', 20, 'resources', struct('cpu', 2, 'ram', 20, 'bandwidth', 60)), ...
    struct('name', 'Low Resources', 'num_vip', 15, 'num_normal', 18, 'resources', struct('cpu', 2, 'ram', 30, 'bandwidth', 60)), ...
    struct('name', 'High Resources', 'num_vip', 15, 'num_normal', 18, 'resources', struct('cpu', 6, 'ram', 100, 'bandwidth', 200)), ...
    struct('name', 'High VIP Users', 'num_vip', 45, 'num_normal', 5, 'resources', struct('cpu', 2, 'ram', 20, 'bandwidth', 60))
};

% حلقه برای هر سناریو
for s = 1:length(scenarios)
    scenario = scenarios{s};
    num_vip = scenario.num_vip;
    num_normal = scenario.num_normal;
    resources = scenario.resources;
    
    fprintf('\n\n=== Scenario: %s ===\n', scenario.name);
    
    % تولید وظایف برای هر روش با seed متفاوت
    rng(1);
    tasks1 = cell(num_vip + num_normal, 1);
    for i = 1:num_vip
        tasks1{i} = struct('name', sprintf('VIP_Task_%d', i), 'priority', 0, 'ram', randi([10, 20]), 'bandwidth', randi([10, 20]), 'duration', randi([3, 5]), 'completed', false, 'start_time', [], 'delay', [], 'cost', 0);
    end
    for i = 1:num_normal
        tasks1{num_vip + i} = struct('name', sprintf('Normal_Task_%d', i), 'priority', 1, 'ram', randi([5, 15]), 'bandwidth', randi([5, 15]), 'duration', randi([3, 5]), 'completed', false, 'start_time', [], 'delay', [], 'cost', 0);
    end
    
    rng(2);
    tasks2 = cell(num_vip + num_normal, 1);
    for i = 1:num_vip
        tasks2{i} = struct('name', sprintf('VIP_Task_%d', i), 'priority', 0, 'ram', randi([10, 20]), 'bandwidth', randi([10, 20]), 'duration', randi([3, 5]), 'completed', false, 'start_time', [], 'delay', [], 'cost', 0);
    end
    for i = 1:num_normal
        tasks2{num_vip + i} = struct('name', sprintf('Normal_Task_%d', i), 'priority', 1, 'ram', randi([5, 15]), 'bandwidth', randi([5, 15]), 'duration', randi([3, 5]), 'completed', false, 'start_time', [], 'delay', [], 'cost', 0);
    end
    
    rng(3);
    tasks3 = cell(num_vip + num_normal, 1);
    for i = 1:num_vip
        tasks3{i} = struct('name', sprintf('VIP_Task_%d', i), 'priority', 0, 'ram', randi([10, 20]), 'bandwidth', randi([10, 20]), 'duration', randi([3, 5]), 'completed', false, 'start_time', [], 'delay', [], 'cost', 0);
    end
    for i = 1:num_normal
        tasks3{num_vip + i} = struct('name', sprintf('Normal_Task_%d', i), 'priority', 1, 'ram', randi([5, 15]), 'bandwidth', randi([5, 15]), 'duration', randi([3, 5]), 'completed', false, 'start_time', [], 'delay', [], 'cost', 0);
    end
    
    rng(4);
    tasks4 = cell(num_vip + num_normal, 1);
    for i = 1:num_vip
        tasks4{i} = struct('name', sprintf('VIP_Task_%d', i), 'priority', 0, 'ram', randi([10, 20]), 'bandwidth', randi([10, 20]), 'duration', randi([3, 5]), 'completed', false, 'start_time', [], 'delay', [], 'cost', 0);
    end
    for i = 1:num_normal
        tasks4{num_vip + i} = struct('name', sprintf('Normal_Task_%d', i), 'priority', 1, 'ram', randi([5, 15]), 'bandwidth', randi([5, 15]), 'duration', randi([3, 5]), 'completed', false, 'start_time', [], 'delay', [], 'cost', 0);
    end
    
    total_tasks = length(tasks1);
    
    % تخصیص مبتنی بر اولویت (Priority-Based)
    current_time = 0;
    completed_tasks_priority = {};
    task_list = tasks1;
    [~, idx] = sort(cellfun(@(x) x.priority, task_list));
    task_list = task_list(idx);
    while ~isempty(task_list)
        for i = 1:length(task_list)
            task = task_list{i};
            if (resources.cpu > 0 && resources.ram >= task.ram && resources.bandwidth >= task.bandwidth)
                resources.cpu = resources.cpu - 1;
                resources.ram = resources.ram - task.ram;
                resources.bandwidth = resources.bandwidth - task.bandwidth;
                task.start_time = current_time;
                current_time = current_time + task.duration;
                resources.cpu = resources.cpu + 1;
                resources.ram = resources.ram + task.ram;
                resources.bandwidth = resources.bandwidth + task.bandwidth;
                task.completed = true;
                task.delay = current_time - task.start_time;
                task.cost = (task.ram * cost_per_ram) + (task.bandwidth * cost_per_bandwidth) + (task.duration * cost_per_time);
                completed_tasks_priority{end+1} = task;
                task_list(i) = [];
                task_list = task_list(~cellfun('isempty', task_list));
                break;
            else
                current_time = current_time + 1;
            end
        end
    end
    
    % تخصیص دینامیک (Dynamic)
    current_time = 0;
    completed_tasks_dynamic = {};
    task_list = tasks2;
    while ~isempty(task_list)
        for i = 1:length(task_list)
            task = task_list{i};
            if (resources.cpu > 0 && resources.ram >= task.ram && resources.bandwidth >= task.bandwidth)
                resources.cpu = resources.cpu - 1;
                resources.ram = resources.ram - task.ram;
                resources.bandwidth = resources.bandwidth - task.bandwidth;
                task.start_time = current_time;
                current_time = current_time + task.duration;
                resources.cpu = resources.cpu + 1;
                resources.ram = resources.ram + task.ram;
                resources.bandwidth = resources.bandwidth + task.bandwidth;
                task.completed = true;
                task.delay = current_time - task.start_time;
                task.cost = (task.ram * cost_per_ram) + (task.bandwidth * cost_per_bandwidth) + (task.duration * cost_per_time);
                completed_tasks_dynamic{end+1} = task;
                task_list(i) = [];
                task_list = task_list(~cellfun('isempty', task_list));
                break;
            else
                current_time = current_time + 1;
            end
        end
    end
    
    % تخصیص مبتنی بر یادگیری ماشین (ML-Based)
    current_time = 0;
    completed_tasks_ml = {};
    task_list = tasks3;
    [~, idx] = sort(cellfun(@(x) x.priority, task_list));
    task_list = task_list(idx);
    while ~isempty(task_list)
        for i = 1:length(task_list)
            task = task_list{i};
            if (resources.cpu > 0 && resources.ram >= task.ram && resources.bandwidth >= task.bandwidth)
                resources.cpu = resources.cpu - 1;
                resources.ram = resources.ram - task.ram;
                resources.bandwidth = resources.bandwidth - task.bandwidth;
                task.start_time = current_time;
                current_time = current_time + task.duration;
                resources.cpu = resources.cpu + 1;
                resources.ram = resources.ram + task.ram;
                resources.bandwidth = resources.bandwidth + task.bandwidth;
                task.completed = true;
                task.delay = current_time - task.start_time;
                task.cost = (task.ram * cost_per_ram) + (task.bandwidth * cost_per_bandwidth) + (task.duration * cost_per_time);
                completed_tasks_ml{end+1} = task;
                task_list(i) = [];
                task_list = task_list(~cellfun('isempty', task_list));
                break;
            else
                current_time = current_time + 1;
            end
        end
    end
    
    % تخصیص مبتنی بر مزایده (Auction-Based)
    current_time = 0;
    completed_tasks_auction = {};
    task_list = tasks4;
    [~, idx] = sort(cellfun(@(x) x.priority, task_list), 'descend');
    task_list = task_list(idx);
    while ~isempty(task_list)
        for i = 1:length(task_list)
            task = task_list{i};
            if (resources.cpu > 0 && resources.ram >= task.ram && resources.bandwidth >= task.bandwidth)
                resources.cpu = resources.cpu - 1;
                resources.ram = resources.ram - task.ram;
                resources.bandwidth = resources.bandwidth - task.bandwidth;
                task.start_time = current_time;
                current_time = current_time + task.duration;
                resources.cpu = resources.cpu + 1;
                resources.ram = resources.ram + task.ram;
                resources.bandwidth = resources.bandwidth + task.bandwidth;
                task.completed = true;
                task.delay = current_time - task.start_time;
                task.cost = (task.ram * cost_per_ram) + (task.bandwidth * cost_per_bandwidth) + (task.duration * cost_per_time);
                completed_tasks_auction{end+1} = task;
                task_list(i) = [];
                task_list = task_list(~cellfun('isempty', task_list));
                break;
            else
                current_time = current_time + 1;
            end
        end
    end
    
    % ارزیابی نتایج
    % Priority-Based
    total_delay_priority = sum(cellfun(@(x) x.delay, completed_tasks_priority));
    total_cost_priority = sum(cellfun(@(x) x.cost, completed_tasks_priority));
    utilization_priority = mean(cellfun(@(x) x.ram, completed_tasks_priority));
    avg_cost_priority = total_cost_priority / length(completed_tasks_priority);
    avg_waiting_time_priority = total_delay_priority / length(completed_tasks_priority);
    total_resource_usage_priority = sum(cellfun(@(x) x.ram + x.bandwidth, completed_tasks_priority));
    system_load_priority = total_resource_usage_priority / (resources.ram + resources.bandwidth + resources.cpu);
    
    % Dynamic
    total_delay_dynamic = sum(cellfun(@(x) x.delay, completed_tasks_dynamic));
    total_cost_dynamic = sum(cellfun(@(x) x.cost, completed_tasks_dynamic));
    utilization_dynamic = mean(cellfun(@(x) x.ram, completed_tasks_dynamic));
    avg_cost_dynamic = total_cost_dynamic / length(completed_tasks_dynamic);
    avg_waiting_time_dynamic = total_delay_dynamic / length(completed_tasks_dynamic);
    total_resource_usage_dynamic = sum(cellfun(@(x) x.ram + x.bandwidth, completed_tasks_dynamic));
    system_load_dynamic = total_resource_usage_dynamic / (resources.ram + resources.bandwidth + resources.cpu);
    
    % ML-Based
    total_delay_ml = sum(cellfun(@(x) x.delay, completed_tasks_ml));
    total_cost_ml = sum(cellfun(@(x) x.cost, completed_tasks_ml));
    utilization_ml = mean(cellfun(@(x) x.ram, completed_tasks_ml));
    avg_cost_ml = total_cost_ml / length(completed_tasks_ml);
    avg_waiting_time_ml = total_delay_ml / length(completed_tasks_ml);
    total_resource_usage_ml = sum(cellfun(@(x) x.ram + x.bandwidth, completed_tasks_ml));
    system_load_ml = total_resource_usage_ml / (resources.ram + resources.bandwidth + resources.cpu);
    
    % Auction-Based
    total_delay_auction = sum(cellfun(@(x) x.delay, completed_tasks_auction));
    total_cost_auction = sum(cellfun(@(x) x.cost, completed_tasks_auction));
    utilization_auction = mean(cellfun(@(x) x.ram, completed_tasks_auction));
    avg_cost_auction = total_cost_auction / length(completed_tasks_auction);
    avg_waiting_time_auction = total_delay_auction / length(completed_tasks_auction);
    total_resource_usage_auction = sum(cellfun(@(x) x.ram + x.bandwidth, completed_tasks_auction));
    system_load_auction = total_resource_usage_auction / (resources.ram + resources.bandwidth + resources.cpu);
    
    % نمایش جدول نتایج
    fprintf('\nEvaluation Results Table:\n');
    fprintf('---------------------------------------------------------------------\n');
    fprintf('| Metric            | Priority-Based | Dynamic    | ML-Based   | Auction-Based |\n');
    fprintf('---------------------------------------------------------------------\n');
    fprintf('| Total Delay       | %-14.2f | %-14.2f | %-14.2f | %-14.2f |\n', total_delay_priority, total_delay_dynamic, total_delay_ml, total_delay_auction);
    fprintf('| Total Cost        | %-14.2f | %-14.2f | %-14.2f | %-14.2f |\n', total_cost_priority, total_cost_dynamic, total_cost_ml, total_cost_auction);
    fprintf('| Utilization       | %-14.2f | %-14.2f | %-14.2f | %-14.2f |\n', utilization_priority, utilization_dynamic, utilization_ml, utilization_auction);
    fprintf('| Avg Cost          | %-14.2f | %-14.2f | %-14.2f | %-14.2f |\n', avg_cost_priority, avg_cost_dynamic, avg_cost_ml, avg_cost_auction);
    fprintf('| Avg Waiting Time  | %-14.2f | %-14.2f | %-14.2f | %-14.2f |\n', avg_waiting_time_priority, avg_waiting_time_dynamic, avg_waiting_time_ml, avg_waiting_time_auction);
    fprintf('| System Load       | %-14.2f | %-14.2f | %-14.2f | %-14.2f |\n', system_load_priority, system_load_dynamic, system_load_ml, system_load_auction);
    fprintf('---------------------------------------------------------------------\n');
    
    % رسم نمودارها
    figure('Position', [100, 100, 1000, 600], 'Name', ['Scenario: ' scenario.name]);
    
    subplot(2, 3, 1);
    bar([total_delay_priority, total_delay_dynamic, total_delay_ml, total_delay_auction]);
    set(gca, 'XTickLabel', {'Priority', 'Dynamic', 'ML', 'Auction'}, 'XTickLabelRotation', 90);
    title('Total Delay');
    ylabel('Units');
    
    subplot(2, 3, 2);
    bar([total_cost_priority, total_cost_dynamic, total_cost_ml, total_cost_auction]);
    set(gca, 'XTickLabel', {'Priority', 'Dynamic', 'ML', 'Auction'}, 'XTickLabelRotation', 90);
    title('Total Cost');
    ylabel('Cost');
    
    subplot(2, 3, 3);
    bar([utilization_priority, utilization_dynamic, utilization_ml, utilization_auction]);
    set(gca, 'XTickLabel', {'Priority', 'Dynamic', 'ML', 'Auction'}, 'XTickLabelRotation', 90);
    title('Utilization');
    ylabel('RAM');
    
    subplot(2, 3, 4);
    bar([avg_cost_priority, avg_cost_dynamic, avg_cost_ml, avg_cost_auction]);
    set(gca, 'XTickLabel', {'Priority', 'Dynamic', 'ML', 'Auction'}, 'XTickLabelRotation', 90);
    title('Avg Cost');
    ylabel('Cost');
    
    subplot(2, 3, 5);
    bar([avg_waiting_time_priority, avg_waiting_time_dynamic, avg_waiting_time_ml, avg_waiting_time_auction]);
    set(gca, 'XTickLabel', {'Priority', 'Dynamic', 'ML', 'Auction'}, 'XTickLabelRotation', 90);
    title('Avg Waiting Time');
    ylabel('Units');
    
    subplot(2, 3, 6);
    bar([system_load_priority, system_load_dynamic, system_load_ml, system_load_auction]);
    set(gca, 'XTickLabel', {'Priority', 'Dynamic', 'ML', 'Auction'}, 'XTickLabelRotation', 90);
    title('System Load');
    ylabel('Load');
end
