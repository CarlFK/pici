// demos.js - SSH Terminal Sidebar Controller

function wssh_run_raw(cmd) {
    const wssh_if = document.getElementById("wssh_if");
    if (wssh_if && wssh_if.contentWindow && wssh_if.contentWindow.wssh) {
        wssh_if.contentWindow.wssh.send(cmd);
    }
}

document.addEventListener('DOMContentLoaded', function() {
    
    // --- Menu Controller ---
    const menuContainer = document.getElementById('term-menu');
    // If we are on a page without the menu (e.g. login), skip
    if (!menuContainer) return;

    function getVisibleItems() {
        // Return only items that are not in a hidden container
        return Array.from(menuContainer.querySelectorAll('.menu-item')).filter(item => {
             return item.offsetParent !== null; // Checks visibility
        });
    }

    function setActive(item) {
        // Remove active from all
        menuContainer.querySelectorAll('.menu-item').forEach(i => i.classList.remove('active'));
        item.classList.add('active');
        item.focus();
    }

    // Input Handling
    menuContainer.addEventListener('keydown', function(e) {
        const visibleItems = getVisibleItems();
        const currentIndex = visibleItems.indexOf(document.activeElement);

        if (e.key === 'ArrowDown') {
            e.preventDefault();
            const next = visibleItems[currentIndex + 1] || visibleItems[0];
            setActive(next);
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            const prev = visibleItems[currentIndex - 1] || visibleItems[visibleItems.length - 1];
            setActive(prev);
        } else if (e.key === 'Enter') {
            e.preventDefault();
            triggerItem(document.activeElement);
        }
    });

    // Click Handling
    menuContainer.addEventListener('click', function(e) {
        const item = e.target.closest('.menu-item');
        if (!item) return;
        setActive(item);
        triggerItem(item);
    });

    function triggerItem(item) {
        // 1. Expand/Collapse Categories
        if (item.classList.contains('category-header')) {
            const category = item.parentElement;
            const children = category.querySelector('.menu-children');
            const indicator = item.querySelector('.indicator');
            
            // Special Case: BYO Category Button logic
            if (category.dataset.category === 'byo') {
                showBYO();
            } else {
                 // Toggle children
                 if (children) {
                     if (children.style.display === 'none') {
                         children.style.display = 'block';
                         indicator.textContent = '▼';
                     } else {
                         children.style.display = 'none';
                         indicator.textContent = '▶';
                     }
                 }
                 // Ensure terminal is visible for demos/tutorials
                 showTerminal();
            }
            return;
        }

        // 2. Demo Execution
        if (item.dataset.cmd) {
            const cmd = item.dataset.cmd;
            const desc = item.dataset.desc;
            run_demo_flow(desc, cmd);
            showTerminal(); // Ensure terminal is shown
            return;
        }

        // 3. Command Line (Free Play)
        if (item.id === 'btn-term-free') {
            showTerminal();
            return;
        }

        // 4. Contribute Guide
        if (item.id === 'btn-contrib') {
            showContrib();
        }

        // 5. Onboarding / Hello World
        if (item.id === 'btn-hello-world') {
            showTerminal();
            run_onboarding();
            return;
        }
    }

    function run_demo_flow(desc, cmd) {
        const script = `
echo
echo "---------------------------------------------------"
echo " DEMO: ${desc}"
echo "---------------------------------------------------"
echo "Command to run: ${cmd}"
echo
read -p "Proceed? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ${cmd}
else
    echo "Cancelled."
fi
`;
        wssh_run_raw(script);
    }

    function run_onboarding() {
        const script = `
clear
echo "Initializing..."
sleep 1
echo "Connecting to FPGA Hardware..."
sleep 1
echo
echo "👋 HELLO WORLD!"
echo "I am your remote FPGA board."
echo
echo "I am going to wave at you now."
echo "Watch the video feed..."
sleep 2
echo
echo ">> Running Blinky (LED Test)..."
cd ~/01_simple_test/v && make load
echo
echo "--------------------------------------"
echo "See the LEDs flashing?"
echo "That was real code running on real hardware."
echo "--------------------------------------"
echo
echo "Welcome to the Lab."
echo "Use the sidebar to explore more demos."
echo
`;
        wssh_run_raw(script);
    }

    // --- View Switchers ---
    function showTerminal() {
        document.getElementById('shared-terminal').style.display = 'block';
        document.getElementById('view-byo').style.display = 'none';
        document.getElementById('view-contrib').style.display = 'none';
    }

    function showBYO() {
        document.getElementById('shared-terminal').style.display = 'none';
        document.getElementById('view-byo').style.display = 'block';
        document.getElementById('view-contrib').style.display = 'none';
    }

    function showContrib() {
        document.getElementById('shared-terminal').style.display = 'none';
        document.getElementById('view-byo').style.display = 'none';
        document.getElementById('view-contrib').style.display = 'block';
    }
});
