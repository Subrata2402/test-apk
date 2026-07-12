import React, { useState, useRef, useEffect } from 'react';
import * as Icons from 'lucide-react';

export default function CustomDropdown({ options, value, onChange, placeholder = 'Select option' }) {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef(null);

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Format options to always be objects { value, label, icon }
  const formattedOptions = options.map(opt => {
    if (typeof opt === 'string') {
      return { value: opt, label: opt };
    }
    return opt;
  });

  const selectedOption = formattedOptions.find(opt => opt.value === value) || { value, label: value || placeholder };
  const SelectedIcon = selectedOption.icon ? Icons[selectedOption.icon] : null;

  return (
    <div className="custom-dropdown" ref={dropdownRef}>
      <button
        type="button"
        className={`dropdown-trigger ${isOpen ? 'open' : ''}`}
        onClick={() => setIsOpen(!isOpen)}
      >
        <div className="trigger-content">
          {SelectedIcon && <SelectedIcon size={16} className="dropdown-item-icon" />}
          <span>{selectedOption.label}</span>
        </div>
        <Icons.ChevronDown size={16} className={`dropdown-arrow ${isOpen ? 'open' : ''}`} />
      </button>

      {isOpen && (
        <div className="dropdown-menu animate-fade-in">
          {formattedOptions.map((opt) => {
            const ItemIcon = opt.icon ? Icons[opt.icon] : null;
            const isSelected = opt.value === value;
            return (
              <button
                key={opt.value}
                type="button"
                className={`dropdown-item ${isSelected ? 'selected' : ''}`}
                onClick={() => {
                  onChange(opt.value);
                  setIsOpen(false);
                }}
              >
                {ItemIcon && <ItemIcon size={16} className="dropdown-item-icon" />}
                <span>{opt.label}</span>
                {isSelected && <Icons.Check size={14} className="check-icon" />}
              </button>
            );
          })}
        </div>
      )}

      <style>{`
        .custom-dropdown {
          position: relative;
          width: 100%;
          text-align: left;
        }

        .dropdown-trigger {
          display: flex;
          align-items: center;
          justify-content: space-between;
          width: 100%;
          padding: 12px 16px;
          background: rgba(0, 0, 0, 0.3);
          border: 1px solid var(--border-color);
          border-radius: 10px;
          color: #ffffff;
          font-family: var(--font-sans);
          font-size: 0.95rem;
          cursor: pointer;
          transition: var(--transition-smooth);
        }

        .dropdown-trigger:focus, .dropdown-trigger.open {
          outline: none;
          border-color: var(--accent-primary);
          box-shadow: 0 0 0 3px var(--accent-primary-glow);
        }

        .trigger-content {
          display: flex;
          align-items: center;
          gap: 10px;
        }

        .dropdown-arrow {
          color: var(--text-secondary);
          transition: transform 0.2s ease;
        }

        .dropdown-arrow.open {
          transform: rotate(180deg);
          color: #ffffff;
        }

        .dropdown-menu {
          position: absolute;
          top: calc(100% + 6px);
          left: 0;
          right: 0;
          background: rgba(15, 15, 25, 0.95);
          backdrop-filter: var(--glass-blur);
          -webkit-backdrop-filter: var(--glass-blur);
          border: 1px solid var(--border-color);
          border-radius: 12px;
          padding: 6px;
          z-index: 1000;
          max-height: 240px;
          overflow-y: auto;
          box-shadow: var(--glass-shadow);
        }

        .dropdown-item {
          display: flex;
          align-items: center;
          gap: 10px;
          width: 100%;
          padding: 10px 12px;
          background: transparent;
          border: none;
          border-radius: 8px;
          color: var(--text-secondary);
          font-family: var(--font-sans);
          font-size: 0.9rem;
          cursor: pointer;
          transition: var(--transition-smooth);
          text-align: left;
        }

        .dropdown-item:hover {
          background: rgba(255, 255, 255, 0.05);
          color: #ffffff;
        }

        .dropdown-item.selected {
          background: var(--accent-primary-glow);
          color: #ffffff;
        }

        .dropdown-item-icon {
          color: var(--text-muted);
        }

        .dropdown-item:hover .dropdown-item-icon,
        .dropdown-item.selected .dropdown-item-icon {
          color: var(--accent-primary);
        }

        .check-icon {
          margin-left: auto;
          color: var(--accent-primary);
        }
      `}</style>
    </div>
  );
}
