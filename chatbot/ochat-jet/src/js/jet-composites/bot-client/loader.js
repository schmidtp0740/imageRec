define(['ojs/ojcore',
    'text!./bot-client.html',
    './bot-client',
    'text!./bot-client.json',
    'css!./bot-client',
    'ojs/ojcomposite'],
        function (oj, view, viewModel, metadata) {
            oj.Composite.register('bot-client', {
                view: {inline: view},
                viewModel: {inline: viewModel},
                metadata: {inline: JSON.parse(metadata)}
            });
        }
);