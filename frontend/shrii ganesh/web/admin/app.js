document.addEventListener('DOMContentLoaded', () => {
    const navItems = document.querySelectorAll('.nav-item');
    const viewSections = document.querySelectorAll('.view-section');

    // Sidebar navigation switching logic
    navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();

            // Remove active class from all menu items & sections
            navItems.forEach(nav => nav.classList.remove('active'));
            viewSections.forEach(sec => sec.classList.remove('active'));

            // Add active class to clicked menu item
            item.classList.add('active');

            // Show target section view
            const targetId = item.getAttribute('data-target');
            const targetSection = document.getElementById(targetId);
            if (targetSection) {
                targetSection.classList.add('active');
            }
        });
    });

    // Logout Action Simulation
    const logoutBtn = document.getElementById('logout-btn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', (e) => {
            e.preventDefault();
            if (confirm('Are you sure you want to log out from the Admin Portal?')) {
                alert('Logged out successfully.');
            }
        });
    }
});
